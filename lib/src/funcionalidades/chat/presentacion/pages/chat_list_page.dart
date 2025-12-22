// lib/src/funcionalidades/chat/presentacion/pages/chat_list_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_room_page.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import '../../../../../graphql/queries.dart';
import '../widgets/chat_list_widgets.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
  
  /// Método estático para refrescar la lista desde fuera
  /// Requiere un GlobalKey<State<ChatListPage>>
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
  bool _showFriends = true; // true = amigos, false = grupos
  int _refreshKey = 0; // Clave para forzar reconstrucción del Query cuando se necesita refrescar
  Future<List<dynamic>>? _friendsFuture; // Future para cargar amigos cuando hay búsqueda
  Future<List<dynamic>>? _friendsForFilterFuture; // Future para cargar amigos para filtrar chats


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Inicializar chat automáticamente al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
      _loadFriendsForFilter();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      // Si hay búsqueda, cargar amigos
      if (query.isNotEmpty) {
        _loadFriendsForSearch();
      } else {
        _friendsFuture = null;
      }
    });
  }

  void _loadFriendsForSearch() {
    final client = GraphQLProvider.of(context).value;
    _friendsFuture = client.query(
      QueryOptions(
        document: gql(GraphQLQueries.getFriends),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    ).then((result) {
      if (result.hasException) {
        return <dynamic>[];
      }
      return result.data?['ListFriends'] as List<dynamic>? ?? <dynamic>[];
    });
  }

  void _loadFriendsForFilter() {
    final client = GraphQLProvider.of(context).value;
    _friendsForFilterFuture = client.query(
      QueryOptions(
        document: gql(GraphQLQueries.getFriends),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    ).then((result) {
      if (result.hasException) {
        return <dynamic>[];
      }
      return result.data?['ListFriends'] as List<dynamic>? ?? <dynamic>[];
    });
  }

  Future<void> _initializeChat() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final firebaseToken = userProvider.firebaseToken;
    final userId = userProvider.firebaseUserId;

    if (firebaseToken != null && userId != null) {
      context.read<ChatBloc>().add(
        InitializeChat(firebaseToken: firebaseToken, userId: userId),
      );
    }
  }

  /// Método público para refrescar la lista de chats
  /// Se llama cuando el usuario vuelve a la página de chats desde la navegación
  /// 
  /// Nota: Usamos una clave única para forzar la reconstrucción del Query widget
  /// en lugar de usar refetch, ya que refetch puede no ser seguro en todos los estados
  void refreshChatList() {
    // Forzar reconstrucción del Query cambiando la clave
    // Esto es más seguro que usar refetch que puede fallar
    if (mounted) {
      setState(() {
        _refreshKey++;
        // Recargar amigos para filtrar chats actualizados
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
    final l10n = AppLocalizations.of(context)!;
    final client = GraphQLProvider.of(context).value;

    try {
      String email = friendEmail ?? '';
      String? photo = friendPhoto;

      // Si no tenemos el email, lo buscamos
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
          // Buscar coincidencia exacta de nickname
          final user = users.firstWhere(
            (u) => u['nickname'] == friendNickname,
            orElse: () => users.first,
          );
          email = user['email'] as String;
          // Si no teníamos la foto, obtenerla del usuario encontrado
          photo ??= user['photo'] as String?;
        } else {
          throw Exception('No se pudo encontrar el email del usuario');
        }
      }

      final chatResult = await client.query(
        QueryOptions(
          document: gql(getOrCreateDirectChatQuery),
          variables: {'userEmail': email},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (chatResult.hasException) {
        throw Exception(chatResult.exception.toString());
      }

      final chat = chatResult.data!['getOrCreateDirectChat'];
      final chatId = chat['id'] as String;

      // Indicar que debe refrescar la lista cuando se vuelva, ya que es un chat nuevo
      _navigateToRoom(chatId, friendNickname, otherUserPhoto: photo, shouldRefreshOnReturn: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _navigateToRoom(String roomId, String roomName, {String? otherUserPhoto, bool shouldRefreshOnReturn = false}) async {
    final chatBloc = context.read<ChatBloc>();

    // Navegar a la sala de chat y esperar el resultado
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: chatBloc,
          child: ChatRoomPage(
            roomId: roomId,
            roomName: roomName,
            otherUserPhoto: otherUserPhoto,
          ),
        ),
      ),
    );

    // Si se volvió después de eliminar un amigo (result == true) o si se creó un chat nuevo (shouldRefreshOnReturn)
    if ((result == true || shouldRefreshOnReturn) && mounted) {
      refreshChatList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de búsqueda y toggle
              ChatSearchBar(
                controller: _searchController,
                showFriends: _showFriends,
                onToggleChanged: (isFriends) {
                  setState(() {
                    _showFriends = isFriends;
                  });
                },
                onSearchChanged: _onSearchChanged,
              ),

              const SizedBox(height: 24),
              Expanded(
                child: _buildChatList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, chatState) {
        if (chatState is ChatConnecting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.connectingToServer),
              ],
            ),
          );
        }

        if (chatState is ChatConnectionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                  Text(l10n.connectionError, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(chatState.message, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _initializeChat,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                ),
              ],
            ),
          );
        }

        // Cargar lista de chats que tienen mensajes
        final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
        
        return Query(
          key: ValueKey('chats_query_$_refreshKey'), // Clave única para forzar reconstrucción
          options: QueryOptions(
            document: gql(myChatsQuery),
            fetchPolicy: FetchPolicy.networkOnly,
          ),
          builder: (chatsResult, {fetchMore, refetch}) {
            // Cargar amigos para filtrar chats de amigos eliminados
            return FutureBuilder<List<dynamic>>(
              future: _friendsForFilterFuture,
              builder: (context, friendsSnapshot) {
                QueryResult? friendsResult;
                
                // Si hay búsqueda y tenemos un future de búsqueda, usar ese
                if (_searchQuery.isNotEmpty && _friendsFuture != null) {
                  return FutureBuilder<List<dynamic>>(
                    future: _friendsFuture,
                    builder: (context, searchFriendsSnapshot) {
                      if (searchFriendsSnapshot.hasData) {
                        friendsResult = QueryResult(
                          options: QueryOptions(document: gql(GraphQLQueries.getFriends)),
                          source: QueryResultSource.network,
                          data: {'ListFriends': searchFriendsSnapshot.data},
                        );
                      } else if (searchFriendsSnapshot.hasError) {
                        friendsResult = QueryResult(
                          options: QueryOptions(document: gql(GraphQLQueries.getFriends)),
                          source: QueryResultSource.network,
                          exception: OperationException(
                            linkException: null,
                            graphqlErrors: [GraphQLError(message: searchFriendsSnapshot.error.toString())],
                          ),
                        );
                      }
                      
                      return _buildChatListContent(
                        chatsResult,
                        friendsResult ?? (friendsSnapshot.hasData 
                          ? QueryResult(
                              options: QueryOptions(document: gql(GraphQLQueries.getFriends)),
                              source: QueryResultSource.network,
                              data: {'ListFriends': friendsSnapshot.data},
                            )
                          : null),
                        currentUserEmail,
                        refetch ?? () {},
                        theme,
                        l10n,
                      );
                    },
                  );
                } else {
                  // Usar el resultado del future de filtro
                  if (friendsSnapshot.hasData) {
                    friendsResult = QueryResult(
                      options: QueryOptions(document: gql(GraphQLQueries.getFriends)),
                      source: QueryResultSource.network,
                      data: {'ListFriends': friendsSnapshot.data},
                    );
                  }
                  
                  return _buildChatListContent(
                    chatsResult,
                    friendsResult,
                    currentUserEmail,
                    refetch ?? () {},
                    theme,
                    l10n,
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatListContent(
    QueryResult chatsResult,
    QueryResult? friendsResult,
    String? currentUserEmail,
    VoidCallback refetch,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    // Mostrar loading si alguna query está cargando
    if (chatsResult.isLoading || (friendsResult != null && friendsResult.isLoading)) {
      return const Center(child: CircularProgressIndicator());
    }

    // Manejar errores
    if (chatsResult.hasException) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(l10n.errorLoadingFriends),
            const SizedBox(height: 8),
            Text(chatsResult.exception.toString()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: refetch,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    final allChats = chatsResult.data?['myChats'] as List<dynamic>? ?? [];
    
    // Obtener lista de amigos para filtrar chats de amigos eliminados
    List<String> friendsNicknames = [];
    if (friendsResult != null && !friendsResult.hasException) {
      final friendsData = friendsResult.data?['ListFriends'] as List<dynamic>? ?? [];
      friendsNicknames = friendsData.map((f) => f['name'] as String? ?? '').where((n) => n.isNotEmpty).toList();
    } else if (_searchQuery.isEmpty) {
      // Si no hay búsqueda activa, cargar amigos para filtrar
      // Esto se hace en un FutureBuilder o Query separado
    }
    
    // Filtrar chats: solo los que tienen mensajes Y (si es directo) el otro usuario sigue siendo amigo
    final chatsWithMessages = allChats.where((chat) {
      final lastMessage = chat['lastMessage'];
      if (lastMessage == null) return false;
      
      // Si es un chat directo, verificar que el otro participante sigue siendo amigo
      final chatType = chat['type'] as String?;
      if (chatType == 'direct' && friendsNicknames.isNotEmpty && currentUserEmail != null) {
        final participants = chat['participants'] as List<dynamic>? ?? [];
        // Buscar el otro participante
        try {
          final otherParticipant = participants.firstWhere(
            (p) => p['userEmail'] != currentUserEmail,
          ) as Map<String, dynamic>?;
          
          if (otherParticipant != null) {
            final otherNickname = otherParticipant['nickname'] as String?;
            // Si el nickname del otro participante no está en la lista de amigos, filtrarlo
            if (otherNickname != null && !friendsNicknames.contains(otherNickname)) {
              return false;
            }
          }
        } catch (e) {
          // Si no se encuentra el otro participante, mantener el chat (fallback)
        }
      }
      
      return true;
    }).toList();
    
    // Convertir chats a formato similar a friends para mantener compatibilidad
    final friends = chatsWithMessages.map((chat) {
      final chatType = chat['type'] as String?;
      final participants = chat['participants'] as List<dynamic>? ?? [];
      
      if (chatType == 'direct' && currentUserEmail != null) {
        // Para chats directos, obtener el otro participante
        Map<String, dynamic>? otherParticipant;
        try {
          otherParticipant = participants.firstWhere(
            (p) => p['userEmail'] != currentUserEmail,
          ) as Map<String, dynamic>?;
        } catch (e) {
          // Si no se encuentra, usar el primer participante (fallback)
          if (participants.isNotEmpty) {
            otherParticipant = participants.first as Map<String, dynamic>?;
          }
        }
        
        return {
          'name': chat['name'] as String? ?? otherParticipant?['nickname'] ?? 'Usuario',
          'photo': otherParticipant?['photoUrl'] as String?,
          'chatId': chat['id'] as String,
          'email': otherParticipant?['userEmail'] as String?,
        };
      } else {
        // Para grupos, usar el nombre del grupo
        return {
          'name': chat['name'] as String? ?? 'Grupo',
          'photo': null,
          'chatId': chat['id'] as String,
          'email': null,
        };
      }
    }).toList();

    // Obtener lista de amigos si hay búsqueda
    List<Map<String, dynamic>> allFriendsList = [];
    if (_searchQuery.isNotEmpty && friendsResult != null && !friendsResult.hasException) {
      final friendsData = friendsResult.data?['ListFriends'] as List<dynamic>? ?? [];
      allFriendsList = friendsData.map((friend) {
        return {
          'name': friend['name'] as String? ?? 'Usuario',
          'photo': friend['photo'] as String?,
          'chatId': null, // No tienen chat creado aún
          'email': null, // No tenemos email en esta query
        };
      }).toList();
    }

    // Combinar chats y amigos, excluyendo duplicados
    // Si hay búsqueda, incluir amigos que no tienen chat
    List<Map<String, dynamic>> combinedList = List.from(friends);
    if (_searchQuery.isNotEmpty) {
      // Agregar amigos que no tienen chat creado
      for (final friend in allFriendsList) {
        final friendName = friend['name'] as String? ?? '';
        // Verificar si ya existe en chats por nombre (ya que no tenemos email en la query de amigos)
        final existsInChats = friends.any((chat) => 
          (chat['name'] as String? ?? '').toLowerCase() == friendName.toLowerCase()
        );
        if (!existsInChats) {
          combinedList.add(friend);
        }
      }
    }

    // Filtrar basado en la búsqueda
    final filteredFriends = _searchQuery.isEmpty
        ? friends
        : combinedList.where((item) {
            final name = item['name'] as String? ?? '';
            return name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    if (chatsWithMessages.isEmpty && _searchQuery.isEmpty) {
      return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noFriendsYet,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.addFriendsToStartChatting),
                  ],
                ),
      );
    }

    if (filteredFriends.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noFriendsFound,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.tryAnotherSearchTerm),
                  ],
                ),
      );
    }

    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de resultados
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0, left: 4),
                    child: Text(
                      _showFriends ? l10n.results : l10n.groupResults, // TODO: Cambiar cuando se implemente búsqueda de grupos
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                Expanded(
                  child: _showFriends
                      ? FriendsList(
                          theme: theme,
                          filteredFriends: filteredFriends,
                          onRefresh: refetch,
                          onFriendTap: (friend) {
                            // Si ya tenemos el chatId, usarlo directamente (chat existente)
                            final chatId = friend['chatId'] as String?;
                            final friendName = friend['name'] as String? ?? 'Usuario';
                            final friendPhoto = friend['photo'] as String?;
                            if (chatId != null) {
                              _navigateToRoom(chatId, friendName, otherUserPhoto: friendPhoto);
                            } else {
                              // Si no hay chatId, crear o abrir el chat (amigo sin chat)
                              _openChatWithFriend(
                                context,
                                friendName,
                                friend['email'] as String?,
                                friendPhoto: friendPhoto,
                              );
                            }
                          },
                        )
                      : GroupsList(theme: theme), // TODO: Pasar filteredGroups cuando se implemente búsqueda de grupos
                ),
      ],
    );
  }
}
