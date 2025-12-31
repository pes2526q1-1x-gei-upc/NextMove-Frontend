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
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/graphql/queries.dart';

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

  String _getTypingText(
    Map<String, String> usersTyping, 
    List<Message> messages,
    Map<String, String>? participantsMap,
    String? currentUserEmail,
  ) {
    if (usersTyping.isEmpty) {
      return '';
    }
    
    // Filtrar el usuario actual de la lista de usuarios escribiendo
    final filteredTypingUsers = usersTyping.entries.where((entry) {
      final userId = entry.key;
      final userName = entry.value;
      
      // Excluir si userId o userName coinciden con el email del usuario actual
      if (currentUserEmail != null) {
        if (userId == currentUserEmail || userName == currentUserEmail) {
          return false;
        }
      }
      return true;
    }).toList();
    
    // Convertir userName a nickname (el backend ahora envía el nickname directamente en userName)
    final typingNicknames = filteredTypingUsers.map((entry) {
      final userName = entry.value; // userName del evento (ahora debería ser el nickname del backend)
      
      // Si userName es un email (fallback del backend si no tiene nickname), buscar en participantsMap
      if (userName.contains('@') && participantsMap != null && participantsMap.containsKey(userName)) {
        return participantsMap[userName]!;
      }
      
      // Si no es un email, ya es el nickname del backend, usarlo directamente
      return userName;
    }).toList();
    
    if (typingNicknames.length == 1) {
      return '${typingNicknames.first} está escribiendo...';
    } else if (typingNicknames.length == 2) {
      return '${typingNicknames[0]} y ${typingNicknames[1]} están escribiendo...';
    } else {
      return '${typingNicknames[0]} y ${typingNicknames.length - 1} más están escribiendo...';
    }
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

  Widget _buildMessagesList(
    List<Message> messages,
    String currentUserEmail,
    Map<String, String>? participantsMap,
  ) {
    final groupedItems = _groupMessagesByDay(messages);
    
    // Función auxiliar para obtener el mensaje en el índice visual dado
    Message? _getMessageAtVisualIndex(List<_ChatItem> items, int visualIndex) {
      final actualIndex = items.length - 1 - visualIndex;
      if (actualIndex < 0 || actualIndex >= items.length) return null;
      return items[actualIndex].message;
    }
    
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
          
          // Determinar si mostrar avatar y nombre basándose en mensajes consecutivos
          bool showAvatar = true;
          bool showSenderName = true;
          
          if (widget.isGroup && !isMe) {
            // En el ListView con reverse: true:
            // - index 0 muestra el mensaje más reciente (arriba)
            // - index n muestra el mensaje más antiguo (abajo)
            // Para obtener el mensaje más reciente (arriba), usamos index - 1
            // Para obtener el mensaje más antiguo (abajo), usamos index + 1
            
            // Avatar: mostrar solo en el último mensaje del grupo consecutivo
            // El último mensaje es el más reciente, así que buscamos si hay uno más reciente del mismo usuario
            final moreRecentMessage = index > 0 ? _getMessageAtVisualIndex(groupedItems, index - 1) : null;
            if (moreRecentMessage != null && moreRecentMessage.senderId == message.senderId) {
              showAvatar = false; // Hay un mensaje más reciente del mismo usuario
            }
            
            // Nombre: mostrar solo en el primer mensaje del grupo consecutivo
            // El primer mensaje es el más antiguo, así que buscamos si hay uno más antiguo del mismo usuario
            final moreAncientMessage = _getMessageAtVisualIndex(groupedItems, index + 1);
            if (moreAncientMessage != null && moreAncientMessage.senderId == message.senderId) {
              showSenderName = false; // Hay un mensaje más antiguo del mismo usuario
            }
          }
          
          // Solo permitir swipe to delete para mensajes propios que no estén eliminados
          if (isMe && !message.deleted) {
            return Builder(
              builder: (builderContext) {
                final builderTheme = Theme.of(builderContext);
                final chatBloc = context.read<ChatBloc>();
                
                return Dismissible(
                  key: Key('message_${message.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: builderTheme.colorScheme.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    // Mostrar diálogo de confirmación
                    final l10n = AppLocalizations.of(builderContext)!;
                    
                    return await showDialog<bool>(
                      context: builderContext,
                      builder: (dialogContext) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: builderTheme.colorScheme.error,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text('Eliminar mensaje'),
                          ],
                        ),
                        content: const Text(
                          '¿Estás seguro de que quieres eliminar este mensaje? Esta acción no se puede deshacer.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: Text(
                              l10n.cancel,
                              style: TextStyle(
                                color: builderTheme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            style: TextButton.styleFrom(
                              foregroundColor: builderTheme.colorScheme.error,
                            ),
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (direction) {
                    chatBloc.add(DeleteMessage(
                      messageId: message.id,
                      roomId: message.roomId,
                    ));
                    
                    // Mostrar SnackBar con confirmación
                    ScaffoldMessenger.of(builderContext).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Mensaje eliminado'),
                          ],
                        ),
                        backgroundColor: builderTheme.colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: MessageBubble(
                    message: message,
                    isMe: isMe,
                    isGroup: widget.isGroup,
                    participantsMap: participantsMap,
                    showAvatar: showAvatar,
                    showSenderName: showSenderName,
                  ),
                );
              },
            );
          }
          
          return MessageBubble(
            message: message,
            isMe: isMe,
            isGroup: widget.isGroup,
            participantsMap: participantsMap,
            showAvatar: showAvatar,
            showSenderName: showSenderName,
          );
        }
        
        return const SizedBox.shrink();
      },
    );
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
    // Usar directamente FirebaseAuth para obtener el email actual, ya que es más confiable
    // cuando el usuario cambia sin reiniciar la app
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? 
                            Provider.of<UserProvider>(context, listen: false).email ?? 
                            Provider.of<UserProvider>(context, listen: false).user?['email'] as String? ?? '';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        titleSpacing: 0,
        title: widget.isGroup 
          ? Query(
              options: QueryOptions(
                document: gql(myChatsQuery),
                fetchPolicy: FetchPolicy.cacheAndNetwork,
              ),
              builder: (result, {fetchMore, refetch}) {
                // Crear mapa de participantes: email -> nickname
                Map<String, String>? participantsMap;
                if (result.data != null) {
                  final chats = result.data?['myChats'] as List<dynamic>? ?? [];
                  final chat = chats.firstWhere(
                    (c) => c['id'] == widget.roomId,
                    orElse: () => null,
                  );
                  if (chat != null) {
                    final participants = chat['participants'] as List<dynamic>? ?? [];
                    final tempMap = <String, String>{};
                    for (var p in participants) {
                      final email = p['userEmail'] as String? ?? '';
                      final nickname = p['nickname'] as String?;
                      if (email.isNotEmpty) {
                        tempMap[email] = nickname ?? email.split('@').first;
                      }
                    }
                    participantsMap = tempMap;
                  }
                }
                
                return BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    final messages = state is ChatRoomActive ? state.messages : <Message>[];
                    final otherUserNickname = _getOtherUserNickname(messages, currentUserEmail);
                    final photoFromMessages = _getOtherUserPhoto(messages, currentUserEmail);
                    final otherUserPhoto = photoFromMessages ?? widget.otherUserPhoto;
                    
                    return _buildAppBarTitle(
                      context,
                      state,
                      messages,
                      otherUserNickname,
                      otherUserPhoto,
                      participantsMap,
                      currentUserEmail,
                    );
                  },
                );
              },
            )
          : BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final messages = state is ChatRoomActive ? state.messages : <Message>[];
                final otherUserNickname = _getOtherUserNickname(messages, currentUserEmail);
                final photoFromMessages = _getOtherUserPhoto(messages, currentUserEmail);
                final otherUserPhoto = photoFromMessages ?? widget.otherUserPhoto;
                
                return _buildAppBarTitle(
                  context,
                  state,
                  messages,
                  otherUserNickname,
                  otherUserPhoto,
                  null,
                  currentUserEmail,
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
          // Si el usuario fue expulsado del grupo, el grupo fue eliminado, o la amistad fue eliminada, cerrar la pantalla
          if ((state is ChatDisconnected || state is GroupDeletedState || state is FriendshipDeletedState) && !_isNavigatingAway) {
            _isNavigatingAway = true;
            String message;
            bool isGroupDeleted = state is GroupDeletedState;
            bool isFriendshipDeleted = state is FriendshipDeletedState;
            
            // Verificar primero si es una amistad eliminada (para chats individuales)
            if (isFriendshipDeleted) {
              final friendshipState = state as FriendshipDeletedState;
              // Verificar que el chat eliminado corresponde al chat actual
              if (friendshipState.chatId == widget.roomId && !widget.isGroup) {
                message = 'La amistad ha sido eliminada';
                debugPrint('[ChatRoomPage] 🗑️ Amistad eliminada, cerrando pantalla del chat ${widget.roomId}...');
              } else {
                // El chat eliminado no es el actual o es un grupo, no hacer nada
                debugPrint('[ChatRoomPage] ⚠️ Amistad eliminada pero no es el chat actual (${friendshipState.chatId} != ${widget.roomId}) o es grupo (${widget.isGroup})');
                _isNavigatingAway = false;
                return;
              }
            } else if (isGroupDeleted) {
              message = 'El grupo ha sido eliminado';
              debugPrint('[ChatRoomPage] 🗑️ Grupo eliminado, cerrando pantalla...');
            } else {
              // Solo mostrar mensaje de expulsión si es un grupo (no un chat individual)
              if (widget.isGroup) {
                message = 'Has sido expulsado del grupo';
                debugPrint('[ChatRoomPage] 🚫 Usuario expulsado, cerrando pantalla...');
              } else {
                // Si no es grupo y llegamos aquí, probablemente es una desconexión normal
                _isNavigatingAway = false;
                return;
              }
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
                Navigator.of(context).pop({
                  'groupDeleted': isGroupDeleted,
                  'friendshipDeleted': isFriendshipDeleted,
                  'leftGroup': false
                });
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
          // Si el usuario fue expulsado, el grupo fue eliminado, o la amistad fue eliminada, mostrar loading mientras se navega
          if (state is ChatDisconnected || state is GroupDeletedState || state is FriendshipDeletedState) {
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
                      : widget.isGroup
                          ? Query(
                              options: QueryOptions(
                                document: gql(myChatsQuery),
                                fetchPolicy: FetchPolicy.cacheAndNetwork,
                              ),
                              builder: (result, {fetchMore, refetch}) {
                                // Crear mapa de participantes: email -> nickname
                                Map<String, String>? participantsMap;
                                if (result.data != null) {
                                  final chats = result.data?['myChats'] as List<dynamic>? ?? [];
                                  final chat = chats.firstWhere(
                                    (c) => c['id'] == widget.roomId,
                                    orElse: () => null,
                                  );
                                  if (chat != null) {
                                    final participants = chat['participants'] as List<dynamic>? ?? [];
                                    final tempMap = <String, String>{};
                                    for (var p in participants) {
                                      final email = p['userEmail'] as String? ?? '';
                                      final nickname = p['nickname'] as String?;
                                      if (email.isNotEmpty) {
                                        tempMap[email] = nickname ?? email.split('@').first;
                                      }
                                    }
                                    participantsMap = tempMap;
                                  }
                                }
                                
                                return _buildMessagesList(messages, currentUserEmail, participantsMap);
                              },
                            )
                          : _buildMessagesList(messages, currentUserEmail, null),
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

  Widget _buildAppBarTitle(
    BuildContext context,
    ChatState state,
    List<Message> messages,
    String? otherUserNickname,
    String? otherUserPhoto,
    Map<String, String>? participantsMap,
    String? currentUserEmail,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
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
                            widget.isGroup 
                              ? _getTypingText(state.usersTyping, state.messages, participantsMap, currentUserEmail)
                              : l10n.typing,
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
  }
}