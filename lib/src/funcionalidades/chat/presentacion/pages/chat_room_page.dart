import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  bool _isTyping = false;
  DateTime? _lastTypingTime;
  late ChatBloc _chatBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Guardar referencia al ChatBloc para usarlo en dispose()
    _chatBloc = context.read<ChatBloc>();
  }

  @override
  void initState() {
    super.initState();
    // Unirse a la sala al entrar
    _chatBloc.add(JoinChatRoom(widget.roomId));
  }

  @override
  void dispose() {
    // Salir de la sala al cerrar
    _chatBloc.add(LeaveChatRoom(widget.roomId));
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleTyping(String text) {
    final now = DateTime.now();
    
    if (text.isEmpty) {
      if (_isTyping) {
        _isTyping = false;
        context.read<ChatBloc>().add(StopTyping(widget.roomId));
      }
      return;
    }

    if (!_isTyping) {
      _isTyping = true;
      context.read<ChatBloc>().add(StartTyping(widget.roomId));
    }

    _lastTypingTime = now;

    // Detener typing después de 3 segundos de inactividad
    Future.delayed(const Duration(seconds: 3), () {
      if (_lastTypingTime != null && 
          now.difference(_lastTypingTime!).inSeconds >= 3 &&
          _isTyping) {
        _isTyping = false;
        context.read<ChatBloc>().add(StopTyping(widget.roomId));
      }
    });
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Detener typing antes de enviar
    if (_isTyping) {
      _isTyping = false;
      context.read<ChatBloc>().add(StopTyping(widget.roomId));
    }

    // Enviar mensaje
    context.read<ChatBloc>().add(SendMessage(
      roomId: widget.roomId,
      content: content,
    ));

    // Limpiar input
    _messageController.clear();

    // Scroll al final
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.firebaseUserId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.roomName,
              style: theme.textTheme.titleMedium,
            ),
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatRoomActive) {
                  if (state.usersTyping.isNotEmpty) {
                    return Text(
                      'escribiendo...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    );
                  }
                  if (state.userCount > 0) {
                    return Text(
                      '${state.userCount} conectados',
                      style: theme.textTheme.bodySmall,
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Navegar a detalles de la sala
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatRoomError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }

          // Scroll al recibir mensaje nuevo
          if (state is ChatRoomActive) {
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }
        },
        builder: (context, state) {
          if (state is ChatConnecting) {
            return const Center(
              child: CircularProgressIndicator(),
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
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          if (state is! ChatRoomActive) {
            return const Center(
              child: Text('Cargando sala...'),
            );
          }

          final messages = state.messages;
          final usersTyping = state.usersTyping;

          return Column(
            children: [
              // Lista de mensajes
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'No hay mensajes aún.\n¡Envía el primero!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length + (usersTyping.isNotEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Mostrar indicador de typing al final
                          if (index == messages.length && usersTyping.isNotEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: TypingIndicator(),
                            );
                          }

                          final message = messages[index];
                          final isMe = message.isSentByMe(currentUserId);
                          final showSender = index == 0 || 
                              messages[index - 1].senderId != message.senderId;

                          return MessageBubble(
                            message: message,
                            isMe: isMe,
                            showSender: showSender && !isMe,
                          );
                        },
                      ),
              ),

              // Input de mensaje
              ChatInput(
                controller: _messageController,
                onChanged: _handleTyping,
                onSend: _sendMessage,
              ),
            ],
          );
        },
      ),
    );
  }
}