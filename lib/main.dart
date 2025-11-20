import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/locale_provider.dart'; 
import 'package:nextmove_app/src/funcionalidades/auth/dominio/auth_service.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/welcome_page.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/bloc/auth_bloc.dart';

import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/map_page.dart';
import 'l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'config/graphql_config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// === IMPORTS PARA EL PERFIL ===
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/edit_user_data_preferences.dart';
// ==============================

final GlobalKey<_NextMoveAppState> appKey = GlobalKey<_NextMoveAppState>();
final UserProvider userProvider = UserProvider();
final LocaleProvider localeProvider = LocaleProvider(); 

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
    // Escuchar cambios de idioma para refrescar la app
    localeProvider.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    localeProvider.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
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
      // Usamos MultiProvider para inyectar Usuario e Idioma
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: userProvider),
          ChangeNotifierProvider.value(value: localeProvider),
        ],
        child: MaterialApp(
          title: 'NextMove',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // Usamos el localeProvider para gestionar el idioma dinámico
          locale: localeProvider.locale, 
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
          
          // ruta de Login para el Logout
          routes: {
            '/login': (context) => BlocProvider(
              create: (context) => AuthBloc(),
              child: const WelcomePage(),
            ),
          },

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
          localeProvider.clearLocale(); // Limpiamos locale también

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
      final authService = AuthService(widget.client.value);
      final meData = await authService.getCurrentUser();
      final firebaseToken = await user.getIdToken();

      if (meData != null && mounted) {
        userProvider.setUser(
          meData,
          firebaseUserId: user.uid,
          firebaseToken: firebaseToken,
        );

        // Sincronizar idioma guardado en backend con la app
        final preferredLanguage = meData['preferredLanguage'] as String?;
        if (preferredLanguage != null) {
          localeProvider.setLocaleFromAPILanguage(preferredLanguage);
        }

        debugPrint("Datos guardados correctamente en Provider");
      } else {
        debugPrint("No se obtuvieron datos del usuario desde GraphQL");
      }
    } catch (e) {
      debugPrint("Error cargando datos del usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoadingUserData) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.loadingUserProfile),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn
      ? const MainScreen()
      : BlocProvider(
        create: (context) => AuthBloc(),
        child: const WelcomePage(),
        );
    
  }
}

// ==========================================
//  PANTALLA PRINCIPAL CON BARRA DE NAVEGACIÓN
// ==========================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  // Lista de Widgets para las pestañas
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    
    // Obtenemos el UID actual de forma segura
    final currentUser = FirebaseAuth.instance.currentUser;
    final String uid = currentUser?.uid ?? '';

    _pages = [
      // 1. Mapa
      const MapPage(),
      
      // 2. Chats
      const ChatsPlaceholder(), 
      
      // 3. Social
      const SocialPlaceholder(), 
      
      // 4. Perfil - Usamos BlocProvider para inyectar UserBloc
      if (uid.isNotEmpty) 
        BlocProvider(
          create: (context) => UserBloc()..add(LoadUserProfile(uid)),
          child: const EditUserDataPreferencesPage(),
        )
      else 
        // Fallback 
        const Center(child: Text("Error: Usuario no identificado")),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos IndexedStack para mantener el estado de las páginas 
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Mapa', 
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Social',
            ),
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
//  PLACEHOLDERS RESTANTES
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