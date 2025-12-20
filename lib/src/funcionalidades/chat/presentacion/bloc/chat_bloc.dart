import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../datos/repositories/chat_repository.dart';
import '../../dominio/entities/message.dart';
import '../../../../../config/socket_config.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// BLoC principal para gestionar el estado del chat
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  
  // Subscripciones a streams
  StreamSubscription<Message>? _messageSubscription;
  StreamSubscription<Map<String, dynamic>>? _typingSubscription;
  StreamSubscription<Map<String, dynamic>>? _userJoinedSubscription;
  StreamSubscription<Map<String, dynamic>>? _userLeftSubscription;

  // Estado local
  String? _currentRoomId;
  final List<Message> _messages = [];
  final Set<String> _usersTyping = {};

  ChatBloc(this._chatRepository) : super(const ChatInitial()) {
    // Registrar handlers de eventos
    on<InitializeChat>(_onInitializeChat);
    on<JoinChatRoom>(_onJoinChatRoom);
    on<LeaveChatRoom>(_onLeaveChatRoom);
    on<SendMessage>(_onSendMessage);
    on<MessageReceived>(_onMessageReceived);
    on<UserStartedTyping>(_onUserStartedTyping);
    on<UserStoppedTyping>(_onUserStoppedTyping);
    on<StartTyping>(_onStartTyping);
    on<StopTyping>(_onStopTyping);
    on<UserJoinedRoom>(_onUserJoinedRoom);
    on<UserLeftRoom>(_onUserLeftRoom);
    on<MarkMessageAsRead>(_onMarkMessageAsRead);
    on<LoadMessageHistory>(_onLoadMessageHistory);
    on<DisconnectChat>(_onDisconnectChat);
    on<ChatError>(_onChatError);
  }

  /// Inicializar conexión de chat
Future<void> _onInitializeChat(
  InitializeChat event,
  Emitter<ChatState> emit,
) async {
  try {
    emit(const ChatConnecting());
    debugPrint('[ChatBloc] Inicializando chat...');

    // Conectar Socket.IO
    await SocketConfig.connect(event.firebaseToken, event.userId);
    await Future.delayed(const Duration(seconds: 1));

    if (!SocketConfig.isConnected) {
      emit(const ChatConnectionError('No se pudo establecer conexión'));
      return;
    }

    // Configurar listeners de streams
    _chatRepository.setupSocketListeners();
    _setupStreamListeners();

    emit(ChatConnected(event.userId));
    debugPrint('[ChatBloc] ✅ Chat inicializado correctamente');
  } catch (e) {
    debugPrint('[ChatBloc] ❌ Error inicializando chat: $e');
    emit(ChatConnectionError(e.toString()));
  }
}

  /// Configurar listeners de los streams del repositorio
  void _setupStreamListeners() {
    // Escuchar mensajes nuevos
    _messageSubscription = _chatRepository.messageStream.listen(
      (message) {
        add(MessageReceived(message));
      },
      onError: (error) {
        debugPrint('[ChatBloc] Error en message stream: $error');
      },
    );

    // Escuchar eventos de typing
    _typingSubscription = _chatRepository.typingStream.listen(
      (data) {
        final userId = data['userId'] as String;
        final userName = data['userName'] as String? ?? userId;
        final roomId = data['roomId'] as String;
        final stopped = data['stopped'] as bool? ?? false;

        if (stopped) {
          add(UserStoppedTyping(roomId: roomId, userId: userId));
        } else {
          add(UserStartedTyping(
            roomId: roomId,
            userId: userId,
            userName: userName,
          ));
        }
      },
      onError: (error) {
        debugPrint('[ChatBloc] Error en typing stream: $error');
      },
    );

    // Escuchar usuarios uniéndose
    _userJoinedSubscription = _chatRepository.userJoinedStream.listen(
      (data) {
        final userId = data['userId'] as String;
        final userName = data['userName'] as String? ?? userId;
        final roomId = data['roomId'] as String;

        add(UserJoinedRoom(
          roomId: roomId,
          userId: userId,
          userName: userName,
        ));
      },
      onError: (error) {
        debugPrint('[ChatBloc] Error en userJoined stream: $error');
      },
    );

    // Escuchar usuarios saliendo
    _userLeftSubscription = _chatRepository.userLeftStream.listen(
      (data) {
        final userId = data['userId'] as String;
        final userName = data['userName'] as String? ?? userId;
        final roomId = data['roomId'] as String;

        add(UserLeftRoom(
          roomId: roomId,
          userId: userId,
          userName: userName,
        ));
      },
      onError: (error) {
        debugPrint('[ChatBloc] Error en userLeft stream: $error');
      },
    );

    debugPrint('[ChatBloc] Stream listeners configurados');
  }

  /// Unirse a una sala de chat
  Future<void> _onJoinChatRoom(
    JoinChatRoom event,
    Emitter<ChatState> emit,
  ) async {
    try {
      debugPrint('[ChatBloc] Uniéndose a sala: ${event.roomId}');

      // Salir de la sala anterior si existe
      if (_currentRoomId != null && _currentRoomId != event.roomId) {
        await _chatRepository.leaveRoom(_currentRoomId!);
      }

      // Unirse a la nueva sala
      await _chatRepository.joinRoom(event.roomId);
      
      _currentRoomId = event.roomId;
      _messages.clear();
      _usersTyping.clear();

      emit(ChatRoomActive(
        roomId: event.roomId,
        messages: List.from(_messages),
        usersTyping: Set.from(_usersTyping),
      ));

      debugPrint('[ChatBloc] ✅ Unido a sala: ${event.roomId}');
    } catch (e) {
      debugPrint('[ChatBloc] ❌ Error uniéndose a sala: $e');
      emit(ChatRoomError(roomId: event.roomId, message: e.toString()));
    }
  }

  /// Salir de una sala de chat
  Future<void> _onLeaveChatRoom(
    LeaveChatRoom event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatRepository.leaveRoom(event.roomId);
      
      if (_currentRoomId == event.roomId) {
        _currentRoomId = null;
        _messages.clear();
        _usersTyping.clear();
      }

      emit(const ChatConnected(''));
    } catch (e) {
      debugPrint('[ChatBloc] Error saliendo de sala: $e');
    }
  }

  /// Enviar mensaje
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      debugPrint('[ChatBloc] 💬 Enviando mensaje a ${event.roomId}');

      await _chatRepository.sendMessage(
        roomId: event.roomId,
        content: event.content,
        type: event.type,
      );

      // El mensaje se agregará cuando llegue via messageStream
    } catch (e) {
      debugPrint('[ChatBloc] ❌ Error enviando mensaje: $e');
      emit(ChatRoomError(roomId: event.roomId, message: e.toString()));
    }
  }

  /// Procesar mensaje recibido
  void _onMessageReceived(
    MessageReceived event,
    Emitter<ChatState> emit,
  ) {
    final message = event.message;
    
    if (message.roomId != _currentRoomId) {
      debugPrint('[ChatBloc] Mensaje de otra sala ignorado');
      return;
    }

    // Agregar mensaje y mantener orden cronológico
    _messages.add(message);
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    debugPrint('[ChatBloc] ✅ Mensaje agregado: ${message.content}');

    if (state is ChatRoomActive) {
      final currentState = state as ChatRoomActive;
      emit(currentState.copyWith(messages: List.from(_messages)));
    }
  }

  /// Usuario empezó a escribir
  void _onUserStartedTyping(
    UserStartedTyping event,
    Emitter<ChatState> emit,
  ) {
    if (event.roomId != _currentRoomId) return;

    _usersTyping.add(event.userId);
    
    if (state is ChatRoomActive) {
      final currentState = state as ChatRoomActive;
      emit(currentState.copyWith(usersTyping: Set.from(_usersTyping)));
    }
  }

  /// Usuario dejó de escribir
  void _onUserStoppedTyping(
    UserStoppedTyping event,
    Emitter<ChatState> emit,
  ) {
    if (event.roomId != _currentRoomId) return;

    _usersTyping.remove(event.userId);
    
    if (state is ChatRoomActive) {
      final currentState = state as ChatRoomActive;
      emit(currentState.copyWith(usersTyping: Set.from(_usersTyping)));
    }
  }

  /// El usuario actual empieza a escribir
  void _onStartTyping(StartTyping event, Emitter<ChatState> emit) {
    _chatRepository.startTyping(event.roomId);
  }

  /// El usuario actual deja de escribir
  void _onStopTyping(StopTyping event, Emitter<ChatState> emit) {
    _chatRepository.stopTyping(event.roomId);
  }

  /// Usuario se unió a la sala
  void _onUserJoinedRoom(UserJoinedRoom event, Emitter<ChatState> emit) {
    if (event.roomId != _currentRoomId) return;

    debugPrint('[ChatBloc] 👤 ${event.userName} se unió');
    
    if (state is ChatRoomActive) {
      final currentState = state as ChatRoomActive;
      emit(currentState.copyWith(userCount: currentState.userCount + 1));
    }
  }

  /// Usuario salió de la sala
  void _onUserLeftRoom(UserLeftRoom event, Emitter<ChatState> emit) {
    if (event.roomId != _currentRoomId) return;

    debugPrint('[ChatBloc] 👋 ${event.userName} salió');
    
    _usersTyping.remove(event.userId);
    
    if (state is ChatRoomActive) {
      final currentState = state as ChatRoomActive;
      emit(currentState.copyWith(
        userCount: currentState.userCount - 1,
        usersTyping: Set.from(_usersTyping),
      ));
    }
  }

  /// Marcar mensaje como leído
  Future<void> _onMarkMessageAsRead(
    MarkMessageAsRead event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatRepository.markMessageAsRead(
        messageId: event.messageId,
        roomId: event.roomId,
      );
    } catch (e) {
      debugPrint('[ChatBloc] Error marcando mensaje como leído: $e');
    }
  }

  /// Cargar historial de mensajes
  Future<void> _onLoadMessageHistory(
    LoadMessageHistory event,
    Emitter<ChatState> emit,
  ) async {
    try {
      if (state is ChatRoomActive) {
        final currentState = state as ChatRoomActive;
        emit(currentState.copyWith(isLoadingHistory: true));
      }

      final messages = await _chatRepository.getRoomMessages(
        event.roomId,
        limit: event.limit,
      );

      // Los mensajes históricos ya vienen ordenados (más antiguos primero)
      // Los insertamos al principio de la lista
      _messages.insertAll(0, messages);

      // Asegurar que todos los mensajes estén ordenados por timestamp
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (state is ChatRoomActive) {
        final currentState = state as ChatRoomActive;
        emit(currentState.copyWith(
          messages: List.from(_messages),
          isLoadingHistory: false,
        ));
      }

      debugPrint('[ChatBloc] ✅ Historial cargado: ${messages.length} mensajes');
    } catch (e) {
      debugPrint('[ChatBloc] ❌ Error cargando historial: $e');
      if (state is ChatRoomActive) {
        final currentState = state as ChatRoomActive;
        emit(currentState.copyWith(isLoadingHistory: false));
      }
    }
  }

  /// Desconectar del chat
  void _onDisconnectChat(DisconnectChat event, Emitter<ChatState> emit) {
    SocketConfig.disconnect();
    _currentRoomId = null;
    _messages.clear();
    _usersTyping.clear();
    emit(const ChatDisconnected());
  }

  /// Manejar error
  void _onChatError(ChatError event, Emitter<ChatState> emit) {
    debugPrint('[ChatBloc] ⚠️ Error: ${event.message}');
    if (_currentRoomId != null) {
      emit(ChatRoomError(roomId: _currentRoomId!, message: event.message));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _userJoinedSubscription?.cancel();
    _userLeftSubscription?.cancel();
    return super.close();
  }
}