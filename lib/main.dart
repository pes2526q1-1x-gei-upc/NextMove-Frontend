import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/map_page.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/auth_service.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/welcome_page.dart';

import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/map_home_page.dart';
import 'l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'config/graphql_config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

final GlobalKey<_NextMoveAppState> appKey = GlobalKey<_NextMoveAppState>();

/// Punto de entrada principal de la aplicación
///
/// Inicializa todos los servicios necesarios antes de arrancar la app:
/// 1. Variables de entorno (.env)
/// 2. Firebase (autenticación y backend)
/// 3. Google Sign In (login con Google)
void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();
  runApp(NextMoveApp(key: appKey));
}

/// Widget raíz de la aplicación
///
/// Configura los providers globales y el tema de la app
/// Es un StatefulWidget para poder cambiar el estado de login desde otras pantallas
class NextMoveApp extends StatefulWidget {
  const NextMoveApp({super.key});

  @override
  State<NextMoveApp> createState() => _NextMoveAppState();
}

class _NextMoveAppState extends State<NextMoveApp> {
  // Cliente de GraphQL para hacer queries y mutations a la API
  late final ValueNotifier<GraphQLClient> client;
  bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    client = GraphQLConfig.initializeClient();
  }

  void setLoggedIn(bool value) {
    setState(() {
      isLoggedIn = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: MaterialApp(
          // Proporciona el UserProvider a toda la app
          // Almacena y gestiona el estado del usuario actual (perfil, preferencias, etc)
          // Fuente: https://pub.dev/packages/provider
          title: 'NextMove',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            return const Locale('en');
          },
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
          // Widget que maneja la autenticación y decide qué pantalla mostrar
          home: AuthStateHandler(client: client, isLoggedIn: isLoggedIn),
        ),
      ),
    );
  }
}

/// Widget que gestiona el estado de autenticación de Firebase
///
/// Responsabilidades:
/// 1. Escuchar cambios en el estado de autenticación (login/logout)
/// 2. Cargar datos del usuario desde GraphQL cuando hay sesión activa
/// 3. Guardar los datos en el UserProvider para acceso global
/// 4. Decidir qué pantalla mostrar (WelcomePage vs MapHomePage)
///
/// Si os preguntáis, para qué queremos esto? pues porque queremos simular persistencia de login.
/// Si el usuario ya se ha logueado cuando cierre y abra la app de nuevo debe tener la sesión abierta
/// Aquí teneis tenéis algunas fuentes donde me he basado el código si os gusta la tortura ;)
/// https://stackoverflow.com/questions/54469191/persist-user-auth-flutter-firebase
/// https://firebase.google.com/docs/auth/flutter/manage-users
/// https://medium.com/@ankith159/flutter-firebase-auth-an-easy-guide-to-persist-user-state-c90c2e53f9df
class AuthStateHandler extends StatefulWidget {
  final ValueNotifier<GraphQLClient> client;
  final bool isLoggedIn;

  const AuthStateHandler({
    super.key,
    required this.client,
    required this.isLoggedIn,
  });

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  bool _isLoadingUserData = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
    _setupAuthListener();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      debugPrint("========================");
      debugPrint("Firebase Auth State Changed");
      debugPrint("User: ${user?.email ?? 'null'}");
      debugPrint("========================");

      if (user != null) {
        // Usuario autenticado - cargar datos
        await _loadUserData(user);

        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            _isLoadingUserData = false;
          });
        }
      } else {
        // Usuario no autenticado - limpiar datos
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).clearUser();

          setState(() {
            _isLoggedIn = false;
            _isLoadingUserData = false;
          });
        }
      }
    });
  }

  Future<void> _loadUserData(User user) async {
    try {
      debugPrint("========================");
      debugPrint("Cargando datos del usuario desde GraphQL...");
      debugPrint("Email: ${user.email}");
      debugPrint("UID: ${user.uid}");
      debugPrint("========================");

      final authService = AuthService(widget.client.value);
      final meData = await authService.getCurrentUser();
      final firebaseToken = await user.getIdToken();

      if (meData != null && mounted) {
        debugPrint("========================");
        debugPrint("Datos del usuario obtenidos:");
        debugPrint("Firebase User ID: ${user.uid}");
        debugPrint("User Data: $meData");
        debugPrint("========================");

        Provider.of<UserProvider>(context, listen: false).setUser(
          meData,
          firebaseUserId: user.uid,
          firebaseToken: firebaseToken,
        );

        debugPrint("Datos guardados correctamente en Provider");
      } else {
        debugPrint("No se obtuvieron datos del usuario desde GraphQL");
      }
    } catch (e, stackTrace) {
      debugPrint("========================");
      debugPrint("Error cargando datos del usuario: $e");
      debugPrint("StackTrace: $stackTrace");
      debugPrint("========================");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUserData) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando datos del usuario...'),
            ],
          ),
        ),
      );
    }

    return MapPage();
  }
}
