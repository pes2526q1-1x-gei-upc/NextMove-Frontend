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
  final String? otherUserPhoto;
  final bool isGroup;

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
  String? _currentRoomName;
  String? _currentGroupPhoto;
  bool _isNavigatingAway = false; // Flag para evitar múltiples navegaciones

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentRoomName = widget.roomName;
    _currentGroupPhoto = widget.otherUserPhoto;
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
      debugPrint('[ChatRoomPage] App vuelve al foreground...');
      
      final isConnected = SocketConfig.isConnected;
      debugPrint('[ChatRoomPage] Socket conectado: $isConnected');
      
      if (!isConnected) {
        debugPrint('[ChatRoomPage] Socket desconectado, reconectando...');
        _reconnectSocket();
      } else {
        _chatBloc.add(LoadMessageHistory(roomId: widget.roomId));
      }
    }
  }

  Future<void> _reconnectSocket() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        debugPrint('[ChatRoomPage] No hay usuario autenticado');
        return;
      }

      final firebaseToken = await firebaseUser.getIdToken();
      final firebaseUserId = firebaseUser.uid;

      if (firebaseToken == null || firebaseToken.isEmpty) {
        debugPrint('[ChatRoomPage] No se pudo obtener token de Firebase');
        return;
      }

      await SocketConfig.connect(firebaseToken, firebaseUserId);
      await Future.delayed(const Duration(milliseconds: 500));
      
      _chatBloc.add(const SocketReconnected());
      _chatBloc.add(JoinChatRoom(widget.roomId));
      _chatBloc.add(LoadMessageHistory(roomId: widget.roomId));
      
      debugPrint('[ChatRoomPage] ✅ Socket reconectado exitosamente');
    } catch (error) {
      debugPrint('[ChatRoomPage] ❌ Error reconectando socket: $error');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Solo intentar salir de la sala si no estamos navegando debido a una expulsión o eliminación
    // y si el widget aún está montado
    if (!_isNavigatingAway) {
      try {
        // Verificar si el BLoC aún está activo antes de agregar eventos
        if (!_chatBloc.isClosed) {
          _chatBloc.add(LeaveChatRoom(widget.roomId));
        }
      } catch (e) {
        // Ignorar errores si el BLoC ya está cerrado
        debugPrint('[ChatRoomPage] Error al salir de la sala en dispose: $e');
      }
    }
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
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

  List<_ChatItem> _groupMessagesByDay(List<Message> messages) {
    if (messages.isEmpty) return [];

    final List<_ChatItem> items = [];
    DateTime? lastDate;

    for (final message in messages) {
      final messageDate = DateTime(
        message.timestamp.year,
        message.timestamp.month,
        message.timestamp.day,
      );

      if (lastDate == null || !_isSameDay(lastDate, messageDate)) {
        items.add(_ChatItem.dateSeparator(messageDate));
        lastDate = messageDate;
      }

      items.add(_ChatItem.message(message));
    }

    return items;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _navigateToFriendDetail(String nickname) async {
    if (nickname.isEmpty) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserNickname = userProvider.user?['nickname'] as String?;
    
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
    
    if (result != null && mounted) {
      final bool shouldPop = result == true || 
          (result is Map<String, dynamic> && 
           ((result as Map<String, dynamic>)['leftGroup'] == true || 
            (result as Map<String, dynamic>)['groupDeleted'] == true));
      if (shouldPop) {
        _chatBloc.add(LeaveChatRoom(widget.roomId));
        final Map<String, dynamic> popResult = {
          'leftGroup': result is Map<String, dynamic> && 
                       (result as Map<String, dynamic>)['leftGroup'] == true,
          'groupDeleted': result is Map<String, dynamic> && 
                          (result as Map<String, dynamic>)['groupDeleted'] == true,
        };
        Navigator.of(context).pop(popResult);
      }
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        titleSpacing: 0,
        title: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final messages = state is ChatRoomActive ? state.messages : <Message>[];
            final otherUserNickname = _getOtherUserNickname(messages, currentUserEmail);
            final photoFromMessages = _getOtherUserPhoto(messages, currentUserEmail);
            final otherUserPhoto = photoFromMessages ?? widget.otherUserPhoto;
            
            return GestureDetector(
              onTap: () async {
                if (widget.isGroup) {
                  final result = await Navigator.of(context).push<Map<String, dynamic>?>(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: _chatBloc,
                        child: ChatRoomDetailsPage(
                          chatId: widget.roomId,
                          chatName: _currentRoomName ?? widget.roomName,
                          chatDescription: null,
                        ),
                      ),
                    ),
                  );
                  
                  if (result is Map<String, dynamic> && mounted) {
                    final resultMap = result;
                    if (resultMap['leftGroup'] == true || resultMap['groupDeleted'] == true) {
                      // Cerrar inmediatamente y volver a la lista de chats
                      // Usar WidgetsBinding para asegurar que se ejecute después del frame actual
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          Navigator.of(context).pop({
                            'leftGroup': resultMap['leftGroup'] == true,
                            'groupDeleted': resultMap['groupDeleted'] == true,
                          });
                        }
                      });
                      return;
                    }
                    
                    setState(() {
                      if (result['name'] != null) {
                        _currentRoomName = result['name'] as String;
                      }
                      if (result['photo'] != null) {
                        _currentGroupPhoto = result['photo'] as String;
                      }
                    });
                  }
                } else if (otherUserNickname != null && otherUserNickname.isNotEmpty) {
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
                    backgroundImage: (widget.isGroup && _currentGroupPhoto != null && _currentGroupPhoto!.isNotEmpty)
                        ? NetworkImage(_currentGroupPhoto!)
                        : (!widget.isGroup && otherUserPhoto != null && otherUserPhoto.isNotEmpty
                            ? NetworkImage(otherUserPhoto)
                            : null),
                    child: (widget.isGroup && (_currentGroupPhoto == null || _currentGroupPhoto!.isEmpty))
                        ? Icon(Icons.group, size: 20, color: theme.colorScheme.onPrimaryContainer)
                        : (!widget.isGroup && (otherUserPhoto == null || otherUserPhoto.isEmpty)
                            ? Icon(Icons.person, size: 20, color: theme.iconTheme.color?.withOpacity(0.8))
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
          // Si el usuario fue expulsado del grupo o el grupo fue eliminado, cerrar la pantalla
          if ((state is ChatDisconnected || state is GroupDeletedState) && !_isNavigatingAway) {
            _isNavigatingAway = true;
            String message;
            bool isGroupDeleted = state is GroupDeletedState;
            if (isGroupDeleted) {
              message = 'El grupo ha sido eliminado';
              debugPrint('[ChatRoomPage] 🗑️ Grupo eliminado, cerrando pantalla...');
            } else {
              message = 'Has sido expulsado del grupo';
              debugPrint('[ChatRoomPage] 🚫 Usuario expulsado, cerrando pantalla...');
            }
            // Mostrar mensaje y navegar inmediatamente
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: theme.colorScheme.error,
                duration: const Duration(seconds: 2),
              ),
            );
            // Navegar inmediatamente usando Future.microtask para asegurar que se ejecute
            Future.microtask(() {
              if (mounted && _isNavigatingAway) {
                debugPrint('[ChatRoomPage] ✅ Navegando de vuelta a la lista de chats...');
                Navigator.of(context).pop({'groupDeleted': isGroupDeleted, 'leftGroup': false});
              } else {
                debugPrint('[ChatRoomPage] ⚠️ No se puede navegar: mounted=$mounted, _isNavigatingAway=$_isNavigatingAway');
              }
            });
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
          // Si el usuario fue expulsado o el grupo fue eliminado, mostrar loading mientras se navega
          if (state is ChatDisconnected || state is GroupDeletedState) {
            return Scaffold(
              backgroundColor: theme.colorScheme.surface,
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (state is! ChatRoomActive) {
            return Center(child: Text(l10n.loadingRoom));
          }
          final messages = state.messages;
          
          return Column(
            children: [
              Expanded(
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
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            final groupedItems = _groupMessagesByDay(messages);
                            
                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              reverse: true,
                              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                              itemCount: groupedItems.length,
                              itemBuilder: (context, index) {
                                final item = groupedItems[groupedItems.length - 1 - index];
                                
                                if (item.isDateSeparator && item.date != null) {
                                  return DateSeparator(date: item.date!);
                                } else if (item.message != null) {
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
              
              Container(
                color: theme.colorScheme.surface, 
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: Padding(
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