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
    // Unirse a la sala al entrar (aquí ya tenemos acceso al ChatBloc)
    _chatBloc.add(JoinChatRoom(widget.roomId));
  }

  @override
  void initState() {
    super.initState();
    // initState() se ejecuta antes que didChangeDependencies()
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
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        titleSpacing: 0,
        title: Row(
          children: [
            // Avatar del chat
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer,
              ),
              child: Center(
                child: Text(
                  widget.roomName.isNotEmpty ? widget.roomName[0].toUpperCase() : '?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.roomName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state is ChatRoomActive) {
                        if (state.usersTyping.isNotEmpty) {
                          return Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'escribiendo...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        }
                        return Text(
                          'En línea',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            onPressed: () {
              // TODO: Mostrar menú con opciones del chat
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Conectando al chat...',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ChatConnectionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.wifi_off,
                        size: 40,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Error de conexión',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver al chat'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! ChatRoomActive) {
            return Center(
              child: Text(
                'Cargando conversación...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                size: 40,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '¡Comienza la conversación!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Envía el primer mensaje para iniciar el chat',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: messages.length + (usersTyping.isNotEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Mostrar indicador de typing al final
                          if (index == messages.length && usersTyping.isNotEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: TypingIndicator(),
                            );
                          }

                          final message = messages[index];
                          final isMe = message.isSentByMe(currentUserId);
                          final showSender = index == 0 ||
                              messages[index - 1].senderId != message.senderId;

                          return Padding(
                            padding: EdgeInsets.only(
                              top: showSender && !isMe ? 16 : 4,
                              bottom: 4,
                            ),
                            child: MessageBubble(
                              message: message,
                              isMe: isMe,
                              showSender: showSender && !isMe,
                            ),
                          );
                        },
                      ),
              ),

              // Input de mensaje con fondo
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 8,
                  left: 16,
                  right: 16,
                  top: 8,
                ),
                child: ChatInput(
                  controller: _messageController,
                  onChanged: _handleTyping,
                  onSend: _sendMessage,
                ),
              ),
            ],
          );
        },
      );