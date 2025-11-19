import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/auth_service.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/welcome_page.dart';

import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/map_page.dart';
import 'l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'config/graphql_config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

final GlobalKey<_NextMoveAppState> appKey = GlobalKey<_NextMoveAppState>();
final UserProvider userProvider = UserProvider();

/// Punto de entrada principal de la aplicación
void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();
  runApp(NextMoveApp(key: appKey));
}

/// Widget raíz de la aplicación
class NextMoveApp extends StatefulWidget {
  const NextMoveApp({super.key});

  @override
  State<NextMoveApp> createState() => _NextMoveAppState();
}

class _NextMoveAppState extends State<NextMoveApp> {
  bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    GraphQLConfig.initializeClient();
  }

  void setLoggedIn(bool value) {
    setState(() {
      isLoggedIn = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: GraphQLConfig.client,
      child: ChangeNotifierProvider.value(
        value: userProvider,
        child: MaterialApp(
          title: 'NextMove',
          debugShowCheckedModeBanner: false,
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
            useMaterial3: true,
          ),
          // Widget que maneja la autenticación y decide qué pantalla mostrar
          home: AuthStateHandler(client: GraphQLConfig.client, isLoggedIn: isLoggedIn),
        ),
      ),
    );
  }
}

/// Widget que gestiona el estado de autenticación de Firebase
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
          userProvider.clearUser();

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

        userProvider.setUser(
          meData,
          firebaseUserId: user.uid,
          firebaseToken: firebaseToken,
        );

        debugPrint("Datos guardados correctamente en Provider");
      } else {
        debugPrint("No se obtuvieron datos del usuario desde GraphQL, lo creamos...");
        
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
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando datos del usuario...'),
            ],
          ),
        ),
      );
    }

    // CAMBIO AQUÍ: Si está logueado, vamos a la MainScreen (con navbar), si no, al WelcomePage
    return _isLoggedIn ? const MainScreen() : WelcomePage();
  }
}

// ==========================================
//  NUEVA IMPLEMENTACIÓN DE NAVEGACIÓN
// ==========================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Lista de pantallas en el orden solicitado:
  // 1. Mapa
  // 2. Chats/Conversaciones
  // 3. Social
  // 4. Perfil
  final List<Widget> _pages = [
    MapPage(),               // Tu página existente
    const ChatsPlaceholder(), // Placeholder (sustituir por tu página real)
    const SocialPlaceholder(), // Placeholder (sustituir por tu página real)
    const ProfilePlaceholder(),// Placeholder (sustituir por tu página real)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El body cambia según el índice seleccionado
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // Oculta texto siempre
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Fixed para evitar animaciones de "shifthing" con >3 items
          backgroundColor: Colors.white, // O el color que prefieras
          selectedItemColor: Theme.of(context).colorScheme.primary, // Color del ícono activo
          unselectedItemColor: Colors.grey, // Color de íconos inactivos
          showSelectedLabels: false,   // REQUISITO: Sin texto
          showUnselectedLabels: false, // REQUISITO: Sin texto
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            // 1. MAPA
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Mapa', 
            ),
            // 2. CHATS
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chats',
            ),
            // 3. SOCIAL
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Social',
            ),
            // 4. PERFIL
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
//  PÁGINAS PLACEHOLDER (Borrar cuando tengas las reales)
// ==========================================

class ChatsPlaceholder extends StatelessWidget {
  const ChatsPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Chats")), body: const Center(child: Text("Pantalla de Chats")));
  }
}

class SocialPlaceholder extends StatelessWidget {
  const SocialPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Social")), body: const Center(child: Text("Pantalla Social")));
  }
}

class ProfilePlaceholder extends StatelessWidget {
  const ProfilePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Perfil")), body: const Center(child: Text("Pantalla de Perfil")));
  }
}