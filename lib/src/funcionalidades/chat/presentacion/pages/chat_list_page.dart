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
import 'create_group_page.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
      _loadFriendsForFilter();
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
    final l10n = AppLocalizations.of(context)!;
    final client = GraphQLProvider.of(context).value;

    try {
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
      floatingActionButton: !_showFriends
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupPage(),
                  ),
                );
                
                if (result == true && mounted) {
                  refreshChatList();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Grupo'),
            )
          : null,
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
                Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
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

        final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
        
        return Query(
          key: ValueKey('chats_query_$_refreshKey'),
          options: QueryOptions(
            document: gql(myChatsQuery),
            fetchPolicy: FetchPolicy.networkOnly,
          ),
          builder: (chatsResult, {fetchMore, refetch}) {
            return FutureBuilder<List<dynamic>>(
              future: _friendsForFilterFuture,
              builder: (context, friendsSnapshot) {
                QueryResult? friendsResult;
                
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
    if (chatsResult.isLoading || (friendsResult != null && friendsResult.isLoading)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatsResult.hasException) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
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
    
    List<String> friendsNicknames = [];
    if (friendsResult != null && !friendsResult.hasException) {
      final friendsData = friendsResult.data?['ListFriends'] as List<dynamic>? ?? [];
      friendsNicknames = friendsData.map((f) => f['name'] as String? ?? '').where((n) => n.isNotEmpty).toList();
    }
    
    // SEPARAR CHATS DIRECTOS Y GRUPOS
    final directChats = allChats.where((chat) {
      final chatType = chat['type'] as String?;
      final lastMessage = chat['lastMessage'];
      
      if (chatType != 'direct' || lastMessage == null) return false;
      
      if (friendsNicknames.isNotEmpty && currentUserEmail != null) {
        final participants = chat['participants'] as List<dynamic>? ?? [];
        try {
          final otherParticipant = participants.firstWhere(
            (p) => p['userEmail'] != currentUserEmail,
          ) as Map<String, dynamic>?;
          
          if (otherParticipant != null) {
            final otherNickname = otherParticipant['nickname'] as String?;
            if (otherNickname != null && !friendsNicknames.contains(otherNickname)) {
              return false;
            }
          }
        } catch (e) {
          // Mantener el chat si no se puede determinar
        }
      }
      
      return true;
    }).toList();
    
    final groupChats = allChats.where((chat) {
      final chatType = chat['type'] as String?;
      return chatType == 'group';
    }).toList();
    
    // Decidir qué mostrar según el toggle
    final chatsToShow = _showFriends ? directChats : groupChats;
    
    // Convertir a formato unificado
    final chatItems = chatsToShow.map((chat) {
      final chatType = chat['type'] as String?;
      final participants = chat['participants'] as List<dynamic>? ?? [];
      
      if (chatType == 'direct' && currentUserEmail != null) {
        Map<String, dynamic>? otherParticipant;
        try {
          otherParticipant = participants.firstWhere(
            (p) => p['userEmail'] != currentUserEmail,
          ) as Map<String, dynamic>?;
        } catch (e) {
          if (participants.isNotEmpty) {
            otherParticipant = participants.first as Map<String, dynamic>?;
          }
        }
        
        return {
          'name': chat['name'] as String? ?? otherParticipant?['nickname'] ?? 'Usuario',
          'photo': otherParticipant?['photoUrl'] as String?,
          'chatId': chat['id'] as String,
          'email': otherParticipant?['userEmail'] as String?,
          'type': 'direct',
        };
      } else {
        return {
          'name': chat['name'] as String? ?? 'Grupo',
          'photo': null,
          'chatId': chat['id'] as String,
          'email': null,
          'type': 'group',
          'description': chat['description'] as String?,
        };
      }
    }).toList();

    // Si mostramos amigos Y hay búsqueda, agregar amigos sin chat
    if (_showFriends && _searchQuery.isNotEmpty && friendsResult != null && !friendsResult.hasException) {
      final friendsData = friendsResult.data?['ListFriends'] as List<dynamic>? ?? [];
      for (final friend in friendsData) {
        final friendName = friend['name'] as String? ?? '';
        final existsInChats = chatItems.any((chat) => 
          (chat['name'] as String? ?? '').toLowerCase() == friendName.toLowerCase()
        );
        if (!existsInChats) {
          chatItems.add({
            'name': friendName,
            'photo': friend['photo'] as String?,
            'chatId': null,
            'email': friend['email'] as String?,
            'type': 'direct',
          });
        }
      }
    }

    // Filtrar por búsqueda
    final filteredItems = _searchQuery.isEmpty
        ? chatItems
        : chatItems.where((item) {
            final name = item['name'] as String? ?? '';
            return name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    // Mensajes de lista vacía
    if (filteredItems.isEmpty && _searchQuery.isEmpty) {
      if (_showFriends) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(l10n.noFriendsYet, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l10n.addFriendsToStartChatting),
            ],
          ),
        );
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_off, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
              const SizedBox(height: 16),
              const Text('No tienes grupos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Crea un grupo para empezar'),
            ],
          ),
        );
      }
    }

    if (filteredItems.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(l10n.noFriendsFound, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l10n.tryAnotherSearchTerm),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, left: 4),
            child: Text(
              _showFriends ? l10n.results : 'Resultados',
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
                  filteredFriends: filteredItems,
                  onRefresh: refetch,
                  onFriendTap: (friend) {
                    final chatId = friend['chatId'] as String?;
                    final friendName = friend['name'] as String? ?? 'Usuario';
                    final friendPhoto = friend['photo'] as String?;
                    
                    if (chatId != null) {
                      _navigateToRoom(chatId, friendName, otherUserPhoto: friendPhoto);
                    } else {
                      _openChatWithFriend(context, friendName, friend['email'] as String?, friendPhoto: friendPhoto);
                    }
                  },
                )
              : _buildGroupsList(theme, filteredItems, refetch),
        ),
      ],
    );
  }

  Widget _buildGroupsList(ThemeData theme, List<Map<String, dynamic>> groups, VoidCallback onRefresh) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 8),
        itemCount: groups.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 0.5,
          color: theme.colorScheme.outline.withOpacity(0.2),
          indent: 72,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final group = groups[index];
          final groupName = group['name'] as String? ?? 'Grupo';
          final groupId = group['chatId'] as String;
          final description = group['description'] as String?;
          
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.group, color: theme.colorScheme.onPrimaryContainer),
            ),
            title: Text(
              groupName,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: description != null && description.isNotEmpty
                ? Text(description, maxLines: 1, overflow: TextOverflow.ellipsis)
                : const Text('Grupo', style: TextStyle(fontStyle: FontStyle.italic)),
            onTap: () => _navigateToRoom(groupId, groupName),
          );
        },
      ),
    );
  }
}