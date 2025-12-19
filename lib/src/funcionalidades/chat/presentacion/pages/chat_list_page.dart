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

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    String? friendEmail,
  ) async {
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Chats',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: Theme.of(context).brightness == Brightness.dark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar chats...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
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

    return BlocBuilder<ChatBloc, ChatState>(
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

        // Cargar lista de amigos para mostrar como chats potenciales
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

            final friends = result.data?['ListFriends'] as List<dynamic>? ?? [];

            // Filtrar amigos basado en la búsqueda
            final filteredFriends = _searchQuery.isEmpty
                ? friends
                : friends.where((friend) {
                    final name = friend['name'] as String? ?? '';
                    return name.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

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
                      'No tienes amigos aún',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text('Agrega amigos para empezar a chatear'),
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
                      'No se encontraron amigos',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Prueba con otro término de búsqueda'),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, left: 4),
                  child: Text(
                    _searchQuery.isNotEmpty ? 'Resultados' : 'Tus amigos',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => refetch!(),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: filteredFriends.length,
                      itemBuilder: (context, index) {
                        final friend = filteredFriends[index];
                        return _buildFriendChatItem(context, friend);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFriendChatItem(BuildContext context, Map<String, dynamic> friend) {
    final theme = Theme.of(context);
    final friendName = friend['name'] as String;
    final friendPhoto = friend['photo'] as String?;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: theme.brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: friendPhoto != null
              ? NetworkImage(friendPhoto)
              : null,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: friendPhoto == null
              ? Text(
                  friendName[0].toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
        title: Text(
          friendName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Toca para chatear',
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        onTap: () => _openChatWithFriend(context, friendName, null),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

}
