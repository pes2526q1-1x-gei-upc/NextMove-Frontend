// lib/src/funcionalidades/chat/presentacion/pages/chat_list_page.dart
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
import 'package:nextmove_app/src/funcionalidades/chat/datos/datasources/chat_queries.dart';
import '../../../../../graphql/queries.dart';
import '../widgets/chat_list_widgets.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showFriends = true; // true = amigos, false = grupos

  @override
  void initState() {
    super.initState();
    // Inicializar chat automáticamente al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
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

  Future<void> _openChatWithFriend(
    BuildContext context,
    String friendNickname,
    String? friendEmail,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final client = GraphQLProvider.of(context).value;

    try {
      String email = friendEmail ?? '';

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

      _navigateToRoom(chatId, friendNickname);
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

  void _navigateToRoom(String roomId, String roomName) {
    final chatBloc = context.read<ChatBloc>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: chatBloc,
          child: ChatRoomPage(roomId: roomId, roomName: roomName),
        ),
      ),
    );
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

        // Cargar lista de amigos para mostrar como chats potenciales
        // TODO: Cuando se implemente grupos en el backend, aquí debería hacerse una query diferente
        // o agregar una segunda query para obtener los grupos del usuario
        return Query(
          options: QueryOptions(
            document: gql(GraphQLQueries.getFriends),
            fetchPolicy: FetchPolicy.networkOnly,
          ),
          builder: (result, {fetchMore, refetch}) {
            if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (result.hasException) {
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
                      Text(result.exception.toString()),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => refetch!(),
                        child: Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }

            final friends = result.data?['ListFriends'] as List<dynamic>? ?? [];

            // Filtrar amigos basado en la búsqueda
            final filteredFriends = _searchQuery.isEmpty
                ? friends
                : friends.where((friend) {
                    final name = friend['name'] as String? ?? '';
                    return name.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

            // TODO: Implementar búsqueda de grupos cuando esté disponible en el backend
            // Cuando se implemente la query para obtener grupos del usuario:
            // final groups = result.data?['userGroups'] as List<dynamic>? ?? [];
            // final filteredGroups = _searchQuery.isEmpty
            //     ? groups
            //     : groups.where((group) {
            //         final name = group['name'] as String? ?? '';
            //         return name.toLowerCase().contains(_searchQuery.toLowerCase());
            //       }).toList();

            if (friends.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Icon(
                        Icons.people_outline,
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
                          onRefresh: () => refetch!(),
                          onFriendTap: (friend) => _openChatWithFriend(context, friend['name'] as String, null),
                        )
                      : GroupsList(theme: theme), // TODO: Pasar filteredGroups cuando se implemente búsqueda de grupos
                ),
              ],
            );
          },
        );
      },
    );
  }

}
