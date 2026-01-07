import '../widgets/chat_room_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_room_details_page.dart';
import '../../dominio/entities/message.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/config/socket_config.dart';
import '../widgets/chat_room_body.dart';
import '../utils/chat_room_data_handler.dart';
import '../utils/chat_navigation_handler.dart';
import 'package:nextmove_app/src/core/services/bad_words_service.dart';

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

class _ChatRoomPageState extends State<ChatRoomPage>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;
  DateTime? _lastTypingTime;
  late ChatBloc _chatBloc;
  String? _currentRoomName;
  String? _currentGroupPhoto;
  bool _isNavigatingAway = false; 
  Message? _editingMessage;
  final BadWordsService _badWordsService = BadWordsService();

  bool get _isEditing => _editingMessage != null;

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

      debugPrint('[ChatRoomPage]  Socket reconectado exitosamente');
    } catch (error) {
      debugPrint('[ChatRoomPage]  Error reconectando socket: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserEmail =
        FirebaseAuth.instance.currentUser?.email ??
        Provider.of<UserProvider>(context, listen: false).email ??
        Provider.of<UserProvider>(context, listen: false).user?['email']
            as String? ??
        '';
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !_isNavigatingAway) {
          // Cuando se sale del chat (con botón de retroceso o gesto),
          // asegurarse de dejar la sala correctamente
          try {
            if (!_chatBloc.isClosed) {
              _chatBloc.add(LeaveChatRoom(widget.roomId));
            }
          } catch (e) {
            debugPrint('[ChatRoomPage] Error al salir de la sala: $e');
          }
        }
      },
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: ChatRoomAppBar(
              isGroup: widget.isGroup,
              roomId: widget.roomId,
              roomName: widget.roomName,
              currentRoomName: _currentRoomName,
              otherUserPhoto: widget.otherUserPhoto,
              currentGroupPhoto: _currentGroupPhoto,
              state: state,
              currentUserEmail: currentUserEmail,
              onNavigateToDetails: _navigateToDetails,
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
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    _scrollToBottom,
                  );
                }
                // Si el usuario fue expulsado del grupo, el grupo fue eliminado, o la amistad fue eliminada, cerrar la pantalla
                if ((state is ChatDisconnected ||
                        state is GroupDeletedState ||
                        state is FriendshipDeletedState) &&
                    !_isNavigatingAway) {
                  _handleExitStates(state, l10n, theme);
                }
              },
              builder: (context, state) {
                return ChatRoomBody(
                  state: state,
                  roomId: widget.roomId,
                  isGroup: widget.isGroup,
                  currentUserEmail: currentUserEmail,
                  scrollController: _scrollController,
                  messageController: _messageController,
                  isEditing: _isEditing,
                  onEditMessage: _startEditingMessage,
                  onDeleteMessage: (msg) => _chatBloc.add(
                    DeleteMessage(messageId: msg.id, roomId: msg.roomId),
                  ),
                  onSendMessage: _sendMessage,
                  onCancelEdit: _cancelEdit,
                  onTextChanged: _handleTyping,
                );
              },
            ),
          );
        },
      ),
    );
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
    final chatBloc = context.read<ChatBloc>();
    Future.delayed(const Duration(seconds: 3), () {
      if (_lastTypingTime != null &&
          DateTime.now().difference(_lastTypingTime!).inSeconds >= 3 &&
          _isTyping) {
        _isTyping = false;
        chatBloc.add(StopTyping(widget.roomId));
      }
    });
  }

  void _sendMessage() async {
    if (!mounted) return;
    
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    
    final chatBloc = context.read<ChatBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Validar palabras ofensivas
    final isOffensive = await _badWordsService.checkOffensiveText(content);
    
    if (!mounted) return;
    
    if (isOffensive) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.offensiveText),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_isTyping) {
      _isTyping = false;
      chatBloc.add(StopTyping(widget.roomId));
    }
    if (_editingMessage != null) {
      // Editar mensaje
      chatBloc.add(
        EditMessage(
          messageId: _editingMessage!.id,
          roomId: _editingMessage!.roomId,
          newContent: content,
        ),
      );
      setState(() {
        _editingMessage = null;
      });
      _messageController.clear();
    } else {
      // Enviar nuevo mensaje
      chatBloc.add(
        SendMessage(roomId: widget.roomId, content: content),
      );
      _messageController.clear();
    }
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _startEditingMessage(Message message) {
    setState(() {
      _editingMessage = message;
      _messageController.text = message.content;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingMessage = null;
      _messageController.clear();
    });
  }

  void _handleExitStates(
    ChatState state,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    _isNavigatingAway = true;
    String message;
    bool isGroupDeleted = state is GroupDeletedState;

    if (state is FriendshipDeletedState) {
      if (state.chatId == widget.roomId && !widget.isGroup) {
        message = l10n.friendshipDeleted;
      } else {
        _isNavigatingAway = false;
        return;
      }
    } else if (isGroupDeleted) {
      message = l10n.groupHasBeenDeleted;
    } else {
      if (widget.isGroup) {
        message = l10n.youHaveBeenKickedFromGroup;
      } else {
        _isNavigatingAway = false;
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.error,
        duration: const Duration(seconds: 2),
      ),
    );

    final navigator = Navigator.of(context);
    Future.microtask(() {
      if (mounted && _isNavigatingAway) {
        navigator.pop({
          'groupDeleted': isGroupDeleted,
          'friendshipDeleted': state is FriendshipDeletedState,
          'leftGroup': false,
        });
      }
    });
  }

  void _navigateToDetails(
    BuildContext context,
    List<Message> messages,
    String currentUserEmail,
    Map<String, String>? participantsMap,
  ) async {
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

      if (result != null && mounted) {
        if (result['leftGroup'] == true || result['groupDeleted'] == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).pop(result);
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
    } else {
      final otherNickname = ChatRoomDataHandler.getOtherNickname(
        messages,
        currentUserEmail,
        widget.roomName,
      );
      _navigateToFriendDetail(otherNickname);
    }
  }

  Future<void> _navigateToFriendDetail(String nickname) async {
    if (nickname.isEmpty) return;

    final result = await ChatNavigationHandler.navigateToFriendDetail<dynamic>(
      context,
      nickname,
    );

    if (result != null && mounted) {
      final bool shouldPop =
          result == true ||
          (result is Map<String, dynamic> &&
              (result['leftGroup'] == true || result['groupDeleted'] == true));
      if (shouldPop) {
        _chatBloc.add(LeaveChatRoom(widget.roomId));
        final Map<String, dynamic> popResult = {
          'leftGroup':
              result is Map<String, dynamic> && result['leftGroup'] == true,
          'groupDeleted':
              result is Map<String, dynamic> && result['groupDeleted'] == true,
        };
        Navigator.of(context).pop(popResult);
      }
    }
  }
}
