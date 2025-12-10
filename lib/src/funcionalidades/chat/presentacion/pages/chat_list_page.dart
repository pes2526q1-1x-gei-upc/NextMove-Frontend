// lib/src/funcionalidades/chat/presentacion/pages/chat_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_room_page.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';

// Query para listar amigos (del módulo de friendship existente)
const String listFriendsQuery = r'''
  query ListFriends {
    ListFriends {
      name
      photo
      email
    }
  }
''';

// Query para obtener email de un usuario por nickname
const String getUserEmailQuery = r'''
  query GetUserEmail($nickname: String!) {
    getUserByNickname(nickname: $nickname) {
      email
    }
  }
''';

// Mutation para abrir chat directo
const String getOrCreateDirectChatMutation = r'''
  query GetOrCreateDirectChat($userEmail: String!) {
    getOrCreateDirectChat(userEmail: $userEmail) {
      id
      type
      name
    }
  }
''';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    _initializeChat();
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
    String friendEmail, // Pasar email directamente
  ) async {
    final client = GraphQLProvider.of(context).value;

    try {
      // Ya no necesitas query de email, lo tienes directamente
      final chatResult = await client.query(
        QueryOptions(
          document: gql(getOrCreateDirectChatMutation),
          variables: {'userEmail': friendEmail},
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
            content: Text('Error: $e'),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar búsqueda
            },
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, chatState) {
          if (chatState is ChatConnecting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Conectando al servidor...'),
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
                  Text('Error de conexión', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(chatState.message, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _initializeChat,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Cargar lista de amigos
          return Query(
            options: QueryOptions(
              document: gql(listFriendsQuery),
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
                      const Text('Error cargando amigos'),
                      const SizedBox(height: 8),
                      Text(result.exception.toString()),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => refetch!(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              final friends =
                  result.data?['ListFriends'] as List<dynamic>? ?? [];

              if (friends.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes amigos aún',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('Agrega amigos para empezar a chatear'),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => refetch!(),
                child: ListView.separated(
                  itemCount: friends.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final nickname = friend['name'] as String;
                    final photo = friend['photo'] as String?;
                    final email = friend['email'] as String;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: photo != null
                            ? NetworkImage(photo)
                            : null,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: photo == null
                            ? Text(
                                nickname[0].toUpperCase(),
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              )
                            : null,
                      ),
                      title: Text(nickname, style: theme.textTheme.titleMedium),
                      subtitle: Text(
                        'Toca para chatear',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chat_bubble_outline,
                        color: theme.colorScheme.primary,
                      ),
                      onTap: () => _openChatWithFriend(context, nickname, email),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
