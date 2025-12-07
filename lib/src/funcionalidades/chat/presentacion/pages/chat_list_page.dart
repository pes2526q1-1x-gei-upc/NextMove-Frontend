import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_room_page.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeChat();
      _initialized = true;
    }
  }

  Future<void> _initializeChat() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final firebaseToken = userProvider.firebaseToken;
    final userId = userProvider.firebaseUserId;

    if (firebaseToken != null && userId != null) {
      context.read<ChatBloc>().add(InitializeChat(
        firebaseToken: firebaseToken,
        userId: userId,
      ));
    }
  }

  void _navigateToRoom(String roomId, String roomName) {
    final chatBloc = context.read<ChatBloc>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: chatBloc,
          child: ChatRoomPage(
            roomId: roomId,
            roomName: roomName,
          ),
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
        builder: (context, state) {
          if (state is ChatConnecting) {
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

          if (state is ChatConnectionError) {
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
                  Text(
                    'Error de conexión',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                  ),
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

          // TODO: Cuando tengas el endpoint GraphQL, cargar las salas reales
          // Por ahora, mostrar salas de prueba
          return _buildTestRoomsList(theme);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar crear nuevo chat
          _showCreateChatDialog(context);
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  Widget _buildTestRoomsList(ThemeData theme) {
    // Salas de prueba para desarrollo
    final testRooms = [
      {'id': 'test-room-1', 'name': 'Sala de Prueba 1', 'lastMessage': 'Hola!'},
      {'id': 'test-room-2', 'name': 'Sala de Prueba 2', 'lastMessage': null},
      {'id': 'test-room-3', 'name': 'Equipo NextMove', 'lastMessage': '¿Cómo va el proyecto?'},
    ];

    return ListView.separated(
      itemCount: testRooms.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: theme.colorScheme.outlineVariant,
      ),
      itemBuilder: (context, index) {
        final room = testRooms[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              room['name']![0],
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          title: Text(
            room['name']!,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: room['lastMessage'] != null
              ? Text(
                  room['lastMessage']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                )
              : null,
          trailing: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          onTap: () => _navigateToRoom(room['id']!, room['name']!),
        );
      },
    );
  }

  void _showCreateChatDialog(BuildContext context) {
    final theme = Theme.of(context);
    final roomIdController = TextEditingController();
    final roomNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Crear nueva sala'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: roomIdController,
              decoration: const InputDecoration(
                labelText: 'ID de la sala',
                hintText: 'ej: my-room-123',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: roomNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la sala',
                hintText: 'ej: Mi Sala de Chat',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final roomId = roomIdController.text.trim();
              final roomName = roomNameController.text.trim();
              
              if (roomId.isNotEmpty && roomName.isNotEmpty) {
                Navigator.of(dialogContext).pop();
                _navigateToRoom(roomId, roomName);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}