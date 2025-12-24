import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/date_separator.dart';
import 'chat_room_details_page.dart';
import '../../dominio/entities/message.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/friend_detail_page.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_event.dart';
import 'package:nextmove_app/config/socket_config.dart';

/// Tipo para representar un item en la lista (puede ser un mensaje o un separador de fecha)
class _ChatItem {
  final Message? message;
  final DateTime? date;
  final bool isDateSeparator;

  _ChatItem.message(this.message) : date = null, isDateSeparator = false;
  _ChatItem.dateSeparator(this.date) : message = null, isDateSeparator = true;
}

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String? otherUserPhoto; // Foto del otro usuario pasada desde la lista
  final bool isGroup; // Indica si es un chat de grupo

  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.roomName,
    this.otherUserPhoto,
    this.isGroup = false,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;
  DateTime? _lastTypingTime;
  late ChatBloc _chatBloc;
  String? _currentRoomName; // Nombre actual del grupo/chat

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentRoomName = widget.roomName; // Inicializar con el nombre pasado
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatBloc = context.read<ChatBloc>();
    _chatBloc.add(JoinChatRoom(widget.roomId));
    _chatBloc.add(LoadMessageHistory(roomId: widget.roomId));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Cuando la app vuelve al foreground, verificar conexión y recargar mensajes
      debugPrint('[ChatRoomPage] App vuelve al foreground...');
      
      // Verificar si el socket está conectado
      final isConnected = SocketConfig.isConnected;
      debugPrint('[ChatRoomPage] Socket conectado: $isConnected');
      
      if (!isConnected) {
        // Si no está conectado, reconectar
        debugPrint('[ChatRoomPage] Socket desconectado, reconectando...');
        _reconnectSocket();
      } else {
        // Si está conectado, solo recargar mensajes
        _chatBloc.add(LoadMessageHistory(roomId: widget.roomId));
      }
    }
  }

  /// Reconectar el socket cuando se detecta desconexión
  Future<void> _reconnectSocket() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        debugPrint('[ChatRoomPage] No hay usuario autenticado');
        return;
      }

      // Obtener un token fresco de Firebase
      final firebaseToken = await firebaseUser.getIdToken();
      final firebaseUserId = firebaseUser.uid;

      if (firebaseToken == null || firebaseToken.isEmpty) {
        debugPrint('[ChatRoomPage] No se pudo obtener token de Firebase');
        return;
      }

      // Reconectar el socket
      await SocketConfig.connect(firebaseToken, firebaseUserId);
      
      // Esperar un poco para que se establezca la conexión
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Disparar evento de reconexión que manejará la reconfiguración de listeners
      _chatBloc.add(const SocketReconnected());
      
      // Volver a unirse a la sala
      _chatBloc.add(JoinChatRoom(widget.roomId));
      
      // Recargar mensajes
      _chatBloc.add(LoadMessageHistory(roomId: widget.roomId));
      
      debugPrint('[ChatRoomPage] ✅ Socket reconectado exitosamente');
    } catch (error) {
      debugPrint('[ChatRoomPage] ❌ Error reconectando socket: $error');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatBloc.add(LeaveChatRoom(widget.roomId));
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // Al usar reverse: true, el "fondo" es la posición 0.0
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
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
    Future.delayed(const Duration(seconds: 3), () {
      if (_lastTypingTime != null &&
          DateTime.now().difference(_lastTypingTime!).inSeconds >= 3 &&
          _isTyping) {
        _isTyping = false;
        context.read<ChatBloc>().add(StopTyping(widget.roomId));
      }
    });
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    if (_isTyping) {
      _isTyping = false;
      context.read<ChatBloc>().add(StopTyping(widget.roomId));
    }
    context.read<ChatBloc>().add(SendMessage(
      roomId: widget.roomId,
      content: content,
    ));
    _messageController.clear();
    // Pequeño delay para asegurar que la UI se actualice antes de hacer scroll
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  String? _getOtherUserNickname(List<Message> messages, String currentUserEmail) {
    if (messages.isEmpty) {
      return widget.roomName.isNotEmpty ? widget.roomName : null;
    }
    for (final message in messages) {
      if (!message.isSentByMe(currentUserEmail)) {
        return message.senderName;
      }
    }
    return widget.roomName.isNotEmpty ? widget.roomName : null;
  }

  String? _getOtherUserPhoto(List<Message> messages, String currentUserEmail) {
    if (messages.isEmpty) return null;
    for (final message in messages) {
      if (!message.isSentByMe(currentUserEmail)) {
        return message.senderPhoto;
      }
    }
    return null;
  }

  /// Agrupa los mensajes por día y retorna una lista de items (mensajes y separadores)
  List<_ChatItem> _groupMessagesByDay(List<Message> messages) {
    if (messages.isEmpty) return [];

    final List<_ChatItem> items = [];
    DateTime? lastDate;

    // Recorrer los mensajes en orden (del más antiguo al más reciente)
    for (final message in messages) {
      final messageDate = DateTime(
        message.timestamp.year,
        message.timestamp.month,
        message.timestamp.day,
      );

      // Si es el primer mensaje o cambió el día, agregar separador de fecha
      if (lastDate == null || !_isSameDay(lastDate, messageDate)) {
        items.add(_ChatItem.dateSeparator(messageDate));
        lastDate = messageDate;
      }

      // Agregar el mensaje
      items.add(_ChatItem.message(message));
    }

    return items;
  }

  /// Verifica si dos fechas son del mismo día
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _navigateToFriendDetail(String nickname) async {
    if (nickname.isEmpty) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserNickname = userProvider.user?['nickname'] as String?;
    
    // Navegar al perfil y esperar el resultado
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<UserBloc>(
                create: (context) {
                  final bloc = UserBloc();
                  bloc.add(LoadUserProfile(nickname));
                  return bloc;
                },
              ),
              BlocProvider<SocialBloc>(
                create: (context) {
                  final socialBloc = SocialBloc();
                  if (currentUserNickname != null && currentUserNickname.isNotEmpty) {
                    socialBloc.add(LoadFriendsEvent(currentUserNickname));
                  }
                  return socialBloc;
                },
              ),
            ],
            child: const FriendDetailsPage(),
          );
        },
      ),
    );
    
    // Si se eliminó la amistad o se bloqueó el usuario (result == true), volver a la lista de chats
    if (result == true && mounted) {
      // Salir de la sala de chat
      _chatBloc.add(LeaveChatRoom(widget.roomId));
      
      // Navegar de vuelta a la lista de chats y pasar true para indicar que se eliminó un amigo o se bloqueó un usuario
      // Esto permitirá que ChatListPage refresque la lista
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserEmail = userProvider.email ?? 
                            userProvider.user?['email'] as String? ?? 
                            FirebaseAuth.instance.currentUser?.email ?? '';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // Importante: permite que el layout cambie cuando sale el teclado
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        titleSpacing: 0,
        title: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final messages = state is ChatRoomActive ? state.messages : <Message>[];
            final otherUserNickname = _getOtherUserNickname(messages, currentUserEmail);
            // Usar la foto de los mensajes si está disponible, sino usar la foto pasada desde la lista
            final photoFromMessages = _getOtherUserPhoto(messages, currentUserEmail);
            final otherUserPhoto = photoFromMessages ?? widget.otherUserPhoto;
            
            return GestureDetector(
              onTap: () async {
                if (widget.isGroup) {
                  // Si es un grupo, navegar a la página de detalles del grupo
                  final result = await Navigator.of(context).push<Map<String, dynamic>?>(
                    MaterialPageRoute(
                      builder: (context) => ChatRoomDetailsPage(
                        chatId: widget.roomId,
                        chatName: _currentRoomName ?? widget.roomName,
                        chatDescription: null, // Podríamos pasar la descripción si la tenemos
                      ),
                    ),
                  );
                  
                  // Si se salió del grupo, volver a la lista de chats
                  if (result != null && result['leftGroup'] == true && mounted) {
                    Navigator.of(context).pop(true); // Devolver true para indicar que se debe refrescar
                    return;
                  }
                  
                  // Si se actualizó el nombre del grupo, actualizar el estado
                  if (result != null && result['name'] != null && mounted) {
                    setState(() {
                      _currentRoomName = result['name'] as String;
                    });
                  }
                } else if (otherUserNickname != null && otherUserNickname.isNotEmpty) {
                  // Si es chat directo, navegar al perfil del amigo
                  _navigateToFriendDetail(otherUserNickname);
                }
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: widget.isGroup
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: !widget.isGroup && otherUserPhoto != null && otherUserPhoto.isNotEmpty
                        ? NetworkImage(otherUserPhoto)
                        : null,
                    child: widget.isGroup
                        ? Icon(
                            Icons.group,
                            size: 20,
                            color: theme.colorScheme.onPrimaryContainer,
                          )
                        : (otherUserPhoto == null || otherUserPhoto.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 20,
                                color: theme.iconTheme.color?.withValues(alpha: 0.8),
                              )
                            : null),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentRoomName ?? widget.roomName,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (state is ChatRoomActive && state.usersTyping.isNotEmpty)
                          Text(
                            l10n.typing,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        elevation: 1,
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
          if (state is ChatRoomActive) {
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }
        },
        builder: (context, state) {
          if (state is ChatConnecting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChatConnectionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(l10n.connectionError, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.back),
                  ),
                ],
              ),
            );
          }
          if (state is! ChatRoomActive) {
            return Center(child: Text(l10n.loadingRoom));
          }
          final messages = state.messages;
          
          return Column(
            children: [
              Expanded(
                // 1. GestureDetector para cerrar teclado al tocar el fondo
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: messages.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noMessagesYet,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            // Agrupar mensajes por día
                            final groupedItems = _groupMessagesByDay(messages);
                            
                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              reverse: true,
                              // 2. keyboardDismissBehavior para cerrar teclado al hacer scroll
                              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                              itemCount: groupedItems.length,
                              itemBuilder: (context, index) {
                                // Invertir índice porque usamos reverse: true
                                final item = groupedItems[groupedItems.length - 1 - index];
                                
                                if (item.isDateSeparator && item.date != null) {
                                  // Mostrar separador de fecha
                                  return DateSeparator(date: item.date!);
                                } else if (item.message != null) {
                                  // Mostrar mensaje
                                  final message = item.message!;
                                  final isMe = message.isSentByMe(currentUserEmail);
                                  return MessageBubble(
                                    message: message,
                                    isMe: isMe,
                                    isGroup: widget.isGroup,
                                  );
                                }
                                
                                return const SizedBox.shrink();
                              },
                            );
                          },
                        ),
                ),
              ),
              
              // 3. SafeArea para el input: Maneja el padding inferior automáticamente
              Container(
                color: theme.colorScheme.surface, 
                child: SafeArea(
                  top: false,
                  bottom: true, // Esto añade ~34px si no hay teclado, y 0 si hay teclado
                  child: Padding(
                    // Padding adicional pequeño para que no quede pegado
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            onChanged: _handleTyping,
                            decoration: InputDecoration(
                              hintText: l10n.writeAMessage,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: theme.colorScheme.primary,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: Icon(Icons.send, color: theme.colorScheme.onPrimary),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}