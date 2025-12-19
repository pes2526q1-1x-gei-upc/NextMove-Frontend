import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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
import 'package:nextmove_app/src/core/theme/app_theme.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/map_page.dart';
import 'l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'config/graphql_config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/profile_page.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/theme_provider.dart';

import 'package:nextmove_app/src/funcionalidades/chat/presentacion/pages/chat_list_page.dart';
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/bloc/chat_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/chat/datos/data/dataproviders/socket_datasource.dart';
import 'package:nextmove_app/src/funcionalidades/chat/datos/repositories/chat_repository_impl.dart';

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
      debugPrint("Firebase Auth State Changed: ${user?.email ?? 'Logged out'}");
      debugPrint("========================");

      if (user != null) {
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
      } else {
        if (mounted) {
          userProvider.clearUser();
          localeProvider.clearLocale();
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

        final preferredLanguage = meData['preferredLanguage'] as String?;
        if (preferredLanguage != null) {
          localeProvider.setLocaleFromAPILanguage(preferredLanguage);
        }

        if (kDebugMode) {
          print("Datos guardados correctamente en Provider");
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

    return _isLoggedIn
        ? const MainScreen()
        : BlocProvider(
            create: (context) => AuthBloc(),
            child: const WelcomePage(),
          );
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _visitedIndices.add(index);
    });
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
              ? const ChatsPlaceholder()
              : const SizedBox.shrink(),

          _visitedIndices.contains(2)
              ? const RankingPlaceholder()
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
          unselectedItemColor: bottomNavTheme.unselectedItemColor ??
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

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc(
      ChatRepositoryImpl(SocketDataSource()),
    );
  }

  @override
  void dispose() {
    _chatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: const ChatListPage(),
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