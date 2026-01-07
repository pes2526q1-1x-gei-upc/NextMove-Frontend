import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_room_page.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import '../../../../../graphql/queries.dart';
import '../widgets/chat_list_widgets.dart';
import '../widgets/chat_list_body.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'create_group_page.dart';
import 'package:nextmove_app/config/socket_config.dart';
import '../utils/chat_list_data_handler.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();

  static void refresh(GlobalKey<State<ChatListPage>>? key) {
    final state = key?.currentState;
    if (state is _ChatListPageState) {
      state.refreshChatList();
    }
  }
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showFriends = true;
  int _refreshKey = 0;
  Future<List<dynamic>>? _friendsFuture;
  Future<List<dynamic>>? _friendsForFilterFuture;
  Timer? _autoRefreshTimer;
  Set<String> _lastKnownGroupIds =
      {}; // IDs de grupos conocidos para detectar cambios
  StreamSubscription<Map<String, dynamic>>? _directChatCreatedSubscription;
  bool _isNavigating = false; // Flag para prevenir múltiples navegaciones

  @override
  void dispose() {
    _searchController.dispose();
    _autoRefreshTimer?.cancel();
    _directChatCreatedSubscription?.cancel();
    // Eliminar listener del socket
    final socket = SocketConfig.socket;
    if (socket != null) {
      socket.off('direct:chat:created');
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
      _loadFriendsForFilter();
      _startAutoRefresh();
      _setupDirectChatCreatedListener();
    });
  }

  void _setupDirectChatCreatedListener() {
    try {
      final socket = SocketConfig.socket;
      if (socket != null && socket.connected) {
        // Eliminar listener previo si existe para evitar duplicados
        socket.off('direct:chat:created');
        socket.on('direct:chat:created', (data) {
          debugPrint('[ChatListPage] Chat directo creado recibido: $data');
          if (mounted) {
            refreshChatList();
          }
        });
        debugPrint(
          '[ChatListPage] Listener de direct:chat:created configurado',
        );
      } else {
        debugPrint(
          '[ChatListPage] Socket no disponible, reintentando en 1 segundo...',
        );
        // Reintentar después de 1 segundo
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _setupDirectChatCreatedListener();
          }
        });
      }
    } catch (e) {
      debugPrint(
        '[ChatListPage] Error configurando listener de chat directo creado: $e',
      );
    }
  }

  void _startAutoRefresh() {
    // Verificar si hay grupos nuevos cada 1 segundos y solo refrescar si hay cambios
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) async {
      if (!mounted) return;

      try {
        final client = GraphQLProvider.of(context).value;
        final result = await client.query(
          QueryOptions(
            document: gql(GraphQLQueries.myChatsQuery),
            fetchPolicy: FetchPolicy.networkOnly,
          ),
        );

        if (result.hasException || !mounted) return;

        final chats = result.data?['myChats'] as List<dynamic>? ?? [];

        // Obtener IDs de grupos actuales usando la utilidad
        final currentGroupIds = ChatListDataHandler.getGroupIds(chats);

        // Comparar con los IDs conocidos
        if (currentGroupIds.length != _lastKnownGroupIds.length ||
            !currentGroupIds.containsAll(_lastKnownGroupIds) ||
            !_lastKnownGroupIds.containsAll(currentGroupIds)) {
          // Hay cambios, refrescar la lista
          debugPrint(
            '[ChatListPage] Detectados cambios en grupos, refrescando lista...',
          );
          _lastKnownGroupIds = currentGroupIds;
          refreshChatList();
        }
      } catch (e) {
        debugPrint('[ChatListPage] Error verificando cambios en grupos: $e');
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isNotEmpty) {
        _loadFriendsForSearch();
      } else {
        _friendsFuture = null;
      }
    });
  }

  void _loadFriendsForSearch() {
    final client = GraphQLProvider.of(context).value;
    _friendsFuture = client
        .query(
          QueryOptions(
            document: gql(GraphQLQueries.getFriends),
            fetchPolicy: FetchPolicy.networkOnly,
          ),
        )
        .then((result) {
          if (result.hasException) {
            return <dynamic>[];
          }
          return result.data?['ListFriends'] as List<dynamic>? ?? <dynamic>[];
        });
  }

  void _loadFriendsForFilter() {
    final client = GraphQLProvider.of(context).value;
    _friendsForFilterFuture = client
        .query(
          QueryOptions(
            document: gql(GraphQLQueries.getFriends),
            fetchPolicy: FetchPolicy.networkOnly,
          ),
        )
        .then((result) {
          if (result.hasException) {
            return <dynamic>[];
          }
          return result.data?['ListFriends'] as List<dynamic>? ?? <dynamic>[];
        });
  }

  Future<void> _initializeChat() async {
    debugPrint('[ChatListPage] Iniciando _initializeChat...');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final firebaseToken = userProvider.firebaseToken;
    final userId = userProvider.firebaseUserId;

    debugPrint(
      '[ChatListPage] firebaseToken: ${firebaseToken != null ? "Disponible" : "NULL"}',
    );
    debugPrint(
      '[ChatListPage] userId: ${userId != null ? "Disponible ($userId)" : "NULL"}',
    );

    if (firebaseToken != null && userId != null) {
      debugPrint('[ChatListPage] Disparando InitializeChat event...');
      context.read<ChatBloc>().add(
        InitializeChat(firebaseToken: firebaseToken, userId: userId),
      );
    } else {
      debugPrint(
        '[ChatListPage] No se puede inicializar chat: token o userId son null',
      );
    }
  }

  void refreshChatList() {
    if (mounted) {
      setState(() {
        _refreshKey++;
        _loadFriendsForFilter();
      });
    }
  }

  Future<void> _openChatWithFriend(
    BuildContext context,
    String friendNickname,
    String? friendEmail, {
    String? friendPhoto,
  }) async {
    // Prevenir múltiples navegaciones simultáneas
    if (_isNavigating) {
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    final l10n = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      final client = GraphQLProvider.of(context).value;
      String email = friendEmail ?? '';
      String? photo = friendPhoto;

      if (email.isEmpty) {
        final emailResult = await client.query(
          QueryOptions(
            document: gql(GraphQLQueries.getUsersByNickname),
            variables: {'nickname': friendNickname},
            fetchPolicy: FetchPolicy.networkOnly,
          ),
        );

        if (emailResult.hasException) {
          throw Exception(emailResult.exception.toString());
        }

        final users = emailResult.data?['UsersByNickname'] as List<dynamic>?;
        if (users != null && users.isNotEmpty) {
          final user = users.firstWhere(
            (u) => u['nickname'] == friendNickname,
            orElse: () => users.first,
          );
          email = user['email'] as String;
          photo ??= user['photo'] as String?;
        } else {
          throw Exception(l10n.couldNotFindUserEmail);
        }
      }

      final chatResult = await client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getOrCreateDirectChatQuery),
          variables: {'userEmail': email},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (chatResult.hasException) {
        throw Exception(chatResult.exception.toString());
      }

      final chat = chatResult.data!['getOrCreateDirectChat'];
      if (chat == null) {
        throw Exception('No se pudo crear el chat');
      }
      
      final chatId = chat['id'] as String?;
      if (chatId == null || chatId.isEmpty) {
        throw Exception('Chat ID no válido');
      }

      debugPrint('[ChatListPage] Chat creado/obtenido: $chatId, navegando...');
      
      // Llamar a _navigateToRoom pero sin resetear el flag _isNavigating
      // porque lo estamos gestionando aquí
      await _navigateToRoom(
        chatId,
        friendNickname,
        otherUserPhoto: photo,
        shouldRefreshOnReturn: true,
        skipNavigationFlag: true,
      );
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  Future<void> _navigateToRoom(
    String roomId,
    String roomName, {
    String? otherUserPhoto,
    bool shouldRefreshOnReturn = false,
    bool isGroup = false,
    bool skipNavigationFlag = false,
  }) async {
    // Prevenir múltiples navegaciones simultáneas
    // Si skipNavigationFlag es true, significa que el flag ya está gestionado por el llamador
    if (!skipNavigationFlag) {
      if (_isNavigating) {
        debugPrint('[ChatListPage] Ya se está navegando, ignorando llamada a _navigateToRoom');
        return;
      }

      setState(() {
        _isNavigating = true;
      });
    }

    try {
      final chatBloc = context.read<ChatBloc>();

      final result = await Navigator.of(context).push<Map<String, dynamic>?>(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: chatBloc,
            child: ChatRoomPage(
              roomId: roomId,
              roomName: roomName,
              otherUserPhoto: otherUserPhoto,
              isGroup: isGroup,
            ),
          ),
        ),
      );

      if (mounted) {
        // Si se eliminó el grupo, se salió del grupo, o hay que refrescar, actualizar la lista
        bool shouldRefresh = shouldRefreshOnReturn;

        if (result is Map<String, dynamic>) {
          final resultMap = result;
          shouldRefresh =
              shouldRefresh ||
              resultMap['groupDeleted'] == true ||
              resultMap['leftGroup'] == true;
        }

        if (shouldRefresh) {
          refreshChatList();
        }
      }
    } catch (e) {
      debugPrint('[ChatListPage] Error en _navigateToRoom: $e');
      // No resetear el flag aquí si skipNavigationFlag es true, 
      // el llamador lo gestionará
    } finally {
      // Solo resetear el flag si lo gestionamos aquí
      if (mounted && !skipNavigationFlag) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is GroupUserAddedState ||
            state is GroupDeletedState ||
            state is UserKickedFromGroupState) {
          debugPrint(
            '[ChatListPage] Refrescando lista de chats debido a: ${state.runtimeType}',
          );
          refreshChatList();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            l10n.chats,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChatSearchBar(
                  controller: _searchController,
                  showFriends: _showFriends,
                  onToggleChanged: (isFriends) =>
                      setState(() => _showFriends = isFriends),
                  onSearchChanged: _onSearchChanged,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ChatListBody(
                    showFriends: _showFriends,
                    searchQuery: _searchQuery,
                    refreshKey: _refreshKey,
                    friendsFuture: _friendsFuture,
                    friendsForFilterFuture: _friendsForFilterFuture,
                    onRefresh: refreshChatList,
                    onNavigateToRoom: _navigateToRoom,
                    onOpenChatWithFriend: _openChatWithFriend,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: AnimatedSwitcher(
          duration: Duration.zero,
          child: !_showFriends
              ? ChatListFab(
                  key: const ValueKey('create-group-fab'),
                  onPressed: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (context) => const CreateGroupPage(),
                      ),
                    );
                    if (result == true && mounted) refreshChatList();
                  },
                )
              : const SizedBox.shrink(key: ValueKey('empty-fab')),
        ),
      ),
    );
  }
}
