import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/competition/competition_page.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/locale_provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/auth_service.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/welcome_page.dart';
import 'package:nextmove_app/src/funcionalidades/registro/presentacion/bloc/auth_bloc.dart';

import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/core/theme/app_theme.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/map_page.dart';
import 'l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'config/graphql_config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/profile_page.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/banned_user_page.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/theme_provider.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/stations_cache.dart';

import 'package:nextmove_app/src/funcionalidades/chat/presentacion/pages/chat_list_page.dart';
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/bloc/chat_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/chat/datos/dataproviders/socket_datasource.dart';
import 'package:nextmove_app/src/funcionalidades/chat/datos/repositories/chat_repository.dart';
import 'package:nextmove_app/config/socket_config.dart';

final GlobalKey<NextMoveAppState> appKey = GlobalKey<NextMoveAppState>();
final UserProvider userProvider = UserProvider();
final LocaleProvider localeProvider = LocaleProvider();
final ThemeProvider themeProvider = ThemeProvider();

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();
  runApp(NextMoveApp(key: appKey));
}

class NextMoveApp extends StatefulWidget {
  const NextMoveApp({super.key});

  @override
  State<NextMoveApp> createState() => NextMoveAppState();
}

class NextMoveAppState extends State<NextMoveApp> {
  bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    GraphQLConfig.initializeClient();
    // Set user email if logged in
    if (FirebaseAuth.instance.currentUser != null) {
      userProvider.setEmail(FirebaseAuth.instance.currentUser!.email);
    }
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
      // UserBloc accesible para toda la app
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: userProvider),
          ChangeNotifierProvider.value(value: localeProvider),
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider(create: (_) => StationsCache()),
          BlocProvider<UserBloc>(create: (_) => UserBloc()),
          BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, theme, _) {
            return MaterialApp(
              title: 'NextMove',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: localeProvider.locale,
              localeResolutionCallback: (locale, supportedLocales) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale?.languageCode) {
                    return supportedLocale;
                  }
                }
                return const Locale('en');
              },
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: theme.themeMode,
              routes: {
                '/login': (context) => BlocProvider(
                  create: (context) => AuthBloc(),
                  child: const WelcomePage(),
                ),
              },
              home: AuthStateHandler(
                client: GraphQLConfig.client,
                isLoggedIn: isLoggedIn,
              ),
            );
          },
        ),
      ),
    );
  }
}

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

class _AuthStateHandlerState extends State<AuthStateHandler> with WidgetsBindingObserver {
  bool _isLoadingUserData = true;
  bool _isLoggedIn = false;
  bool _isBanned = false;
  Map<String, dynamic>? _banInfo;
  Timer? _banCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isLoggedIn = widget.isLoggedIn;
    if (_isLoggedIn) {
      _handleUserLogin(FirebaseAuth.instance.currentUser!);
    }
    _setupAuthListener();
    _startBanCheckTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _banCheckTimer?.cancel();
    super.dispose();
  }

  void _startBanCheckTimer() {
    // Verificar estado de baneo cada 2 segundos mientras el usuario está logueado
    _banCheckTimer?.cancel();
    _banCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_isLoggedIn && !_isBanned) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && mounted) {
          _loadUserData(user);
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Verificar estado de baneo cuando la app vuelve al foreground
    // Esto es especialmente útil para iOS donde no llegan notificaciones push
    if (state == AppLifecycleState.resumed && _isLoggedIn) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _loadUserData(user);
      }
    }
  }

  Future<void> _handleUserLogin(User user) async {
    await _loadUserData(user);

    if (mounted) {
      context.read<UserBloc>().add(LoadUserProfile(user.uid));
    }

    if (mounted) {
      setState(() {
        _isLoggedIn = true;
        _isLoadingUserData = false;
      });
    }
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      debugPrint("========================");
      debugPrint("Firebase Auth State Changed: ${user?.email ?? 'Logged out'}");
      debugPrint("========================");

      if (user != null) {
        await _handleUserLogin(user);
        _startBanCheckTimer();
      } else {
        if (mounted) {
          // Desconectar el socket cuando el usuario cierra sesión
          SocketConfig.disconnect();
          userProvider.clearUser();
          localeProvider.clearLocale();
          _banCheckTimer?.cancel();
          setState(() {
            _isLoggedIn = false;
            _isLoadingUserData = false;
            _isBanned = false;
          });
        }
      }
    });
  }

  Future<void> _loadUserData(User user) async {
    debugPrint("Loading user data for ${user.email}");
    try {
      final authService = AuthService(widget.client.value);
      final meData = await authService.getCurrentUser();
      debugPrint("meData: $meData");
      final firebaseToken = await user.getIdToken();

      if (meData != null && mounted) {
        final isBanned = meData['isBanned'] as bool? ?? false;

        if (kDebugMode) {
          debugPrint("=== Estado de baneo ===");
          debugPrint("isBanned: $isBanned");
          debugPrint("banInfo: ${meData['banInfo']}");
          debugPrint("========================");
        }

        if (isBanned) {
          // Usuario baneado - actualizar estado para mostrar pantalla de baneo
          if (kDebugMode) {
            debugPrint("Usuario baneado detectado, mostrando pantalla de baneo");
          }
          setState(() {
            _isBanned = true;
          _banInfo = meData['banInfo'] as Map<String, dynamic>?;
            _isLoadingUserData = false;
          });
          return;
        }

        // Usuario no está baneado - cargar datos normalmente
        if (kDebugMode && _isBanned) {
          debugPrint("Usuario desbaneado detectado, redirigiendo a pantalla principal");
        }

        userProvider.setUser(
          meData,
          firebaseUserId: user.uid,
          firebaseToken: firebaseToken,
        );

        if (kDebugMode) {
          print("Firebase token: $firebaseToken");
        }
        
        final preferredLanguage = meData['preferredLanguage'] as String?;
        if (preferredLanguage != null) {
          localeProvider.setLocaleFromAPILanguage(preferredLanguage);
        }
        final fireBaseUser = FirebaseAuth.instance.currentUser;
        if (fireBaseUser != null) {
          final token = await fireBaseUser.getIdToken();
          debugPrint('Bearer $token') ;
        }
        if (kDebugMode) {
          print("Datos guardados correctamente en Provider");
        }

        // Actualizar estado después de cargar todos los datos
        if (mounted) {
          setState(() {
            _isBanned = false;
            _banInfo = null;
            _isLoadingUserData = false;
          });
        }
      } else {
        if (kDebugMode) {
          print("No se obtuvieron datos del usuario desde GraphQL");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error cargando datos del usuario: $e");
      }
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

    if (kDebugMode) {
      debugPrint("User banned?: $_isBanned");
    }

    if (_isBanned) {
      // Si el usuario está baneado, mostrar solo la página de baneo
      // No permitir navegación a otras partes de la app
      return PopScope(
        canPop: false, // Prevenir que el usuario salga de la página de baneo
        child: BannedUserPage(
          banInfo: _banInfo,
          client: widget.client,
          onUnbanned: () {
            // Cuando el usuario es desbaneado, recargar datos
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              _loadUserData(user);
            }
          },
        ),
      );
    } else {
      return _isLoggedIn
          ? const MainScreen()
          : BlocProvider(
              create: (context) => AuthBloc(),
              child: const WelcomePage(),
            );
    }
  }
}

// ==========================================
//  PANTALLA PRINCIPAL
// ==========================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final Set<int> _visitedIndices = {0};
  final GlobalKey<_ChatsPlaceholderState> _chatsPlaceholderKey = GlobalKey<_ChatsPlaceholderState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _visitedIndices.add(index);
    });
    
    // Si se selecciona la página de chats (índice 1), refrescar la lista
    if (index == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _chatsPlaceholderKey.currentState?.refreshChatList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomNavTheme = theme.bottomNavigationBarTheme;
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const MapPage(),

          _visitedIndices.contains(1)
              ? ChatsPlaceholder(key: _chatsPlaceholderKey)
              : const SizedBox.shrink(),

          _visitedIndices.contains(2)
              ? const CompetitionPage()
              : const SizedBox.shrink(),

          _visitedIndices.contains(3)
              ? const ProfilePage()
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor:
              bottomNavTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
          selectedItemColor:
              bottomNavTheme.selectedItemColor ?? theme.colorScheme.primary,
          unselectedItemColor:
              bottomNavTheme.unselectedItemColor ??
              theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'Ranking',
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

class ChatsPlaceholder extends StatefulWidget {
  const ChatsPlaceholder({super.key});
  
  @override
  State<ChatsPlaceholder> createState() => _ChatsPlaceholderState();
}

class _ChatsPlaceholderState extends State<ChatsPlaceholder> {
  late final ChatBloc _chatBloc;
  final GlobalKey<State<ChatListPage>> _chatListPageKey = GlobalKey<State<ChatListPage>>();

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc(
      ChatRepository(SocketDataSource()),
    );
  }

  @override
  void dispose() {
    _chatBloc.close();
    super.dispose();
  }

  /// Método público para refrescar la lista de chats
  /// Se llama desde MainScreen cuando se selecciona el índice de chat
  void refreshChatList() {
    ChatListPage.refresh(_chatListPageKey);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: ChatListPage(key: _chatListPageKey),
    );
  }
}

class RankingPlaceholder extends StatelessWidget {
  const RankingPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ranking")),
      body: const Center(child: Text("Pantalla de Ranking")),
    );
  }
}
