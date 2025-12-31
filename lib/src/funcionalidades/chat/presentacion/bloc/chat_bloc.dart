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
  StreamSubscription<Map<String, dynamic>>? _messageDeletedSubscription;
  StreamSubscription<Message>? _messageEditedSubscription;
  StreamSubscription<Map<String, dynamic>>? _userKickedSubscription;
  StreamSubscription<Map<String, dynamic>>? _groupUserAddedSubscription;
  StreamSubscription<Map<String, dynamic>>? _groupParticipantKickedSubscription;
  StreamSubscription<Map<String, dynamic>>? _friendshipDeletedSubscription;

  // Estado local
  String? _currentRoomId;
  final List<Message> _messages = [];
  final Map<String, String> _usersTyping = {}; // userId -> userName

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
    on<SocketReconnected>(_onSocketReconnected);
    on<DeleteMessage>(_onDeleteMessage);
    on<MessageDeleted>(_onMessageDeleted);
    on<EditMessage>(_onEditMessage);
    on<MessageEdited>(_onMessageEdited);
    on<UserKickedFromGroup>(_onUserKickedFromGroup);
    on<GroupUserAdded>(_onGroupUserAdded);
    on<GroupParticipantKicked>(_onGroupParticipantKicked);
    on<GroupDeleted>(_onGroupDeleted);
    on<FriendshipDeleted>(_onFriendshipDeleted);
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

    // Configurar callback de reconexión
    SocketConfig.setReconnectCallback(() {
      add(const SocketReconnected());
    });

    // Socket.IO maneja el heartbeat automáticamente con ping/pong nativo
    // No es necesario un keep-alive personalizado

    emit(ChatConnected(event.userId));
    debugPrint('[ChatBloc] ✅ Chat inicializado correctamente');
  } catch (e) {
    debugPrint('[ChatBloc] ❌ Error inicializando chat: $e');
    emit(ChatConnectionError(e.toString()));
  }
}

  /// Configurar listeners de los streams del repositorio
  void _setupStreamListeners() {
    // Cancelar suscripciones anteriores si existen
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _userJoinedSubscription?.cancel();
    _userLeftSubscription?.cancel();
    _messageDeletedSubscription?.cancel();
    _messageEditedSubscription?.cancel();
    _userKickedSubscription?.cancel();
    _groupUserAddedSubscription?.cancel();

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
        final userEmail = data['userEmail'] as String?; // Email si está disponible
        final roomId = data['roomId'] as String;
        final stopped = data['stopped'] as bool? ?? false;

        if (stopped) {
          add(UserStoppedTyping(roomId: roomId, userId: userId));
        } else {
          add(UserStartedTyping(
            roomId: roomId,
            userId: userId,
            userName: userName,
            userEmail: userEmail,
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

    // Escuchar mensajes eliminados
    _messageDeletedSubscription = _chatRepository.socketDataSource.messageDeletedStream.listen(
      (data) {
        debugPrint('[ChatBloc] 📨 Evento message:deleted recibido: $data');
        final messageId = data['messageId'] as String?;
        final roomId = data['roomId'] as String?;
        
        if (messageId != null && roomId != null) {
          debugPrint('[ChatBloc] 🗑️ Procesando eliminación de mensaje $messageId en sala $roomId');
          add(MessageDeleted(messageId: messageId, roomId: roomId));
        } else {
          debugPrint('[ChatBloc] ⚠️ Datos incompletos en message:deleted: messageId=$messageId, roomId=$roomId');
        }
      },
      onError: (error) {
        debugPrint('[ChatBloc] ❌ Error en messageDeleted stream: $error');
      },
    );

    // Escuchar mensajes editados
    _messageEditedSubscription = _chatRepository.socketDataSource.messageEditedStream.listen(
      (messageModel) {
        debugPrint('[ChatBloc] 📨 Evento message:edited recibido: ${messageModel.id}');
        add(MessageEdited(messageModel.toEntity()));
      },
      onError: (error) {
        debugPrint('[ChatBloc] ❌ Error en messageEdited stream: $error');
      },
    );

    // Escuchar usuario expulsado de grupo
    _userKickedSubscription = _chatRepository.userKickedStream.listen(
      (data) {
        debugPrint('[ChatBloc] 🚫 Usuario expulsado del grupo: $data');
        final chatId = data['chatId'] as String?;
        final chatName = data['chatName'] as String? ?? 'Grupo';
        if (chatId != null) {
          add(UserKickedFromGroup(chatId: chatId, chatName: chatName));
        }
      },
      onError: (error) {
        debugPrint('[ChatBloc] ❌ Error en userKicked stream: $error');
      },
    );

    // Escuchar usuario añadido a grupo
    _groupUserAddedSubscription = _chatRepository.groupUserAddedStream.listen(
      (data) {
        debugPrint('[ChatBloc] ➕ Usuario añadido a grupo: $data');
        final chatId = data['chatId'] as String?;
        final chatName = data['chatName'] as String? ?? 'Grupo';
        if (chatId != null) {
          add(GroupUserAdded(chatId: chatId, chatName: chatName));
        }
      },
      onError: (error) {
        debugPrint('[ChatBloc] ❌ Error en groupUserAdded stream: $error');
      },
    );

    // Escuchar participante expulsado de grupo
    _groupParticipantKickedSubscription = _chatRepository.groupParticipantKickedStream.listen(
      (data) {
        debugPrint('[ChatBloc] 🚫 Participante expulsado del grupo: $data');
        final chatId = data['chatId'] as String?;
        final chatName = data['chatName'] as String? ?? 'Grupo';
        if (chatId != null) {
          add(GroupParticipantKicked(chatId: chatId, chatName: chatName));
        }
      },
      onError: (error) {
        debugPrint('[ChatBloc] ❌ Error en groupParticipantKicked stream: $error');
      },
    );

    // Escuchar grupo eliminado
    _chatRepository.groupDeletedStream.listen(
      (data) {
        debugPrint('[ChatBloc] 🗑️ Grupo eliminado: $data');
        final chatId = data['chatId'] as String?;
        final chatName = data['chatName'] as String? ?? 'Grupo Eliminado';
        if (chatId != null) {
          add(GroupDeleted(chatId: chatId, chatName: chatName));
        }
      },
      onError: (error) {
        debugPrint('[ChatBloc] ❌ Error en groupDeleted stream: $error');
      },
    );

    // Escuchar amistad eliminada (chat directo eliminado)
    _friendshipDeletedSubscription = _chatRepository.friendshipDeletedStream.listen(
      (data) {
        debugPrint('[ChatBloc] 🗑️ Amistad eliminada (chat eliminado): $data');
        final chatId = data['chatId'] as String?;
        final deletedBy = data['deletedBy'] as String? ?? '';
        final deletedByNickname = data['deletedByNickname'] as String? ?? '';
        if (chatId != null) {
          add(FriendshipDeleted(
            chatId: chatId,
            deletedBy: deletedBy,
            deletedByNickname: deletedByNickname,
          ));
        }
      },
      onError: (error) {
        debugPrint('[ChatBloc] ❌ Error en friendshipDeleted stream: $error');
      },
    );

    debugPrint('[ChatBloc] ✅ Stream listeners configurados (incluyendo messageDeleted, messageEdited, userKicked, groupUserAdded, groupParticipantKicked y friendshipDeleted)');
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
        usersTyping: Map.from(_usersTyping),
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

    // Si userEmail está disponible, usarlo en lugar de userName para poder buscarlo en participantsMap
    // Si no está disponible, usar userName como antes
    _usersTyping[event.userId] = event.userEmail ?? event.userName;
    
    if (state is ChatRoomActive) {
      final currentState = state as ChatRoomActive;
      emit(currentState.copyWith(usersTyping: Map.from(_usersTyping)));
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
      emit(currentState.copyWith(usersTyping: Map.from(_usersTyping)));
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
        usersTyping: Map.from(_usersTyping),
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

      // Crear un mapa de mensajes existentes por ID para evitar duplicados
      final existingMessagesMap = <String, Message>{};
      for (final msg in _messages) {
        existingMessagesMap[msg.id] = msg;
      }
      
      // Agregar o actualizar mensajes del historial
      int newCount = 0;
      for (final message in messages) {
        if (!existingMessagesMap.containsKey(message.id)) {
          _messages.add(message);
          newCount++;
        }
      }
      
      if (newCount > 0) {
        debugPrint('[ChatBloc] 📥 Agregando $newCount mensajes nuevos del historial');
      }

      // Asegurar que todos los mensajes estén ordenados por timestamp
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (state is ChatRoomActive) {
        final currentState = state as ChatRoomActive;
        emit(currentState.copyWith(
          messages: List.from(_messages),
          isLoadingHistory: false,
        ));
      }

      debugPrint('[ChatBloc] ✅ Historial cargado: ${messages.length} mensajes totales, ${_messages.length} en lista');
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

  /// Manejar reconexión del socket
  Future<void> _onSocketReconnected(
    SocketReconnected event,
    Emitter<ChatState> emit,
  ) async {
    try {
      debugPrint('[ChatBloc] 🔄 Manejando reconexión del socket...');
      
      // Reconfigurar listeners de Socket.IO y streams
      _chatRepository.resetSocketListeners();
      _setupStreamListeners();
      
      // Si hay una sala activa, volver a unirse
      if (_currentRoomId != null) {
        debugPrint('[ChatBloc] Re-uniéndose a sala: $_currentRoomId');
        await _chatRepository.joinRoom(_currentRoomId!);
        
        // Si estamos en una sala activa, mantener el estado
        if (state is ChatRoomActive) {
          final currentState = state as ChatRoomActive;
          emit(currentState);
        }
      }
      
      debugPrint('[ChatBloc] ✅ Reconexión manejada correctamente');
    } catch (e) {
      debugPrint('[ChatBloc] ❌ Error manejando reconexión: $e');
    }
  }


  /// Eliminar mensaje
  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    int? messageIndex;
    try {
      debugPrint('[ChatBloc] 🗑️ Eliminando mensaje ${event.messageId}');
      
      // Actualizar estado local inmediatamente para feedback visual rápido
      messageIndex = _messages.indexWhere((m) => m.id == event.messageId);
      if (messageIndex != -1 && state is ChatRoomActive) {
        final message = _messages[messageIndex];
        _messages[messageIndex] = message.copyWith(
          deleted: true,
          deletedAt: DateTime.now(),
        );
        final currentState = state as ChatRoomActive;
        emit(currentState.copyWith(messages: List.from(_messages)));
        debugPrint('[ChatBloc] ✅ Estado local actualizado inmediatamente');
      }
      
      await _chatRepository.deleteMessage(
        messageId: event.messageId,
        roomId: event.roomId,
      );

      // El mensaje también se actualizará cuando llegue el evento message:deleted via socket
      // (esto asegura sincronización con otros usuarios)
    } catch (e) {
      debugPrint('[ChatBloc] ❌ Error eliminando mensaje: $e');
      // Revertir cambio local si falla
      if (messageIndex != null && messageIndex != -1 && state is ChatRoomActive) {
        final message = _messages[messageIndex];
        _messages[messageIndex] = message.copyWith(
          deleted: false,
          deletedAt: null,
        );
        final currentState = state as ChatRoomActive;
        emit(currentState.copyWith(messages: List.from(_messages)));
      }
      emit(ChatRoomError(roomId: event.roomId, message: e.toString()));
    }
  }

  /// Mensaje eliminado (recibido desde Socket.IO)
  void _onMessageDeleted(
    MessageDeleted event,
    Emitter<ChatState> emit,
  ) {
    debugPrint('[ChatBloc] 🔄 Handler _onMessageDeleted llamado: messageId=${event.messageId}, roomId=${event.roomId}, currentRoomId=$_currentRoomId');
    
    if (event.roomId != _currentRoomId) {
      debugPrint('[ChatBloc] ⚠️ Mensaje eliminado de otra sala ignorado (${event.roomId} != $_currentRoomId)');
      return;
    }

    // Buscar el mensaje en la lista y marcarlo como eliminado
    final messageIndex = _messages.indexWhere((m) => m.id == event.messageId);
    debugPrint('[ChatBloc] 📋 Buscando mensaje ${event.messageId} en lista de ${_messages.length} mensajes. Índice encontrado: $messageIndex');
    
    if (messageIndex != -1) {
      final message = _messages[messageIndex];
      _messages[messageIndex] = message.copyWith(
        deleted: true,
        deletedAt: DateTime.now(),
      );
      
      debugPrint('[ChatBloc] ✅ Mensaje marcado como eliminado: ${event.messageId}. Estado actual: ${state.runtimeType}');

      if (state is ChatRoomActive) {
        final currentState = state as ChatRoomActive;
        emit(currentState.copyWith(messages: List.from(_messages)));
        debugPrint('[ChatBloc] ✅ Estado actualizado con mensaje eliminado');
      } else {
        debugPrint('[ChatBloc] ⚠️ Estado no es ChatRoomActive, no se puede actualizar');
      }
    } else {
      debugPrint('[ChatBloc] ⚠️ Mensaje a eliminar no encontrado en la lista: ${event.messageId}');
      debugPrint('[ChatBloc] 📋 IDs de mensajes en lista: ${_messages.map((m) => m.id).toList()}');
    }
  }

  /// Editar mensaje
  Future<void> _onEditMessage(
    EditMessage event,
    Emitter<ChatState> emit,
  ) async {
    int? messageIndex;
    try {
      debugPrint('[ChatBloc] ✏️ Editando mensaje ${event.messageId}');
      
      // Actualizar estado local inmediatamente para feedback visual rápido
      messageIndex = _messages.indexWhere((m) => m.id == event.messageId);
      if (messageIndex != -1 && state is ChatRoomActive) {
        final message = _messages[messageIndex];
        _messages[messageIndex] = message.copyWith(
          content: event.newContent,
          edited: true,
          editedAt: DateTime.now(),
        );
        final currentState = state as ChatRoomActive;
        emit(currentState.copyWith(messages: List.from(_messages)));
        debugPrint('[ChatBloc] ✅ Estado local actualizado inmediatamente');
      }
      
      await _chatRepository.editMessage(
        messageId: event.messageId,
        roomId: event.roomId,
        newContent: event.newContent,
      );

      // El mensaje también se actualizará cuando llegue el evento message:edited via socket
      // (esto asegura sincronización con otros usuarios)
    } catch (e) {
      debugPrint('[ChatBloc] ❌ Error editando mensaje: $e');
      // Revertir cambio local si falla
      if (messageIndex != null && messageIndex != -1 && state is ChatRoomActive) {
        final originalMessage = _messages[messageIndex];
        // Buscar el mensaje original en el estado anterior
        _messages[messageIndex] = originalMessage.copyWith(
          edited: false,
          editedAt: null,
        );
        final currentState = state as ChatRoomActive;
        emit(currentState.copyWith(messages: List.from(_messages)));
      }
      emit(ChatRoomError(roomId: event.roomId, message: e.toString()));
    }
  }

  /// Mensaje editado (recibido desde Socket.IO)
  void _onMessageEdited(
    MessageEdited event,
    Emitter<ChatState> emit,
  ) {
    final editedMessage = event.message;
    
    if (editedMessage.roomId != _currentRoomId) {
      debugPrint('[ChatBloc] ⚠️ Mensaje editado de otra sala ignorado');
      return;
    }

    // Buscar el mensaje en la lista y actualizarlo
    final messageIndex = _messages.indexWhere((m) => m.id == editedMessage.id);
    
    if (messageIndex != -1) {
      _messages[messageIndex] = editedMessage;
      debugPrint('[ChatBloc] ✅ Mensaje actualizado: ${editedMessage.id}');

      if (state is ChatRoomActive) {
        final currentState = state as ChatRoomActive;
        emit(currentState.copyWith(messages: List.from(_messages)));
      }
    } else {
      debugPrint('[ChatBloc] ⚠️ Mensaje editado no encontrado en la lista: ${editedMessage.id}');
    }
  }

  /// Usuario expulsado de grupo
  void _onUserKickedFromGroup(
    UserKickedFromGroup event,
    Emitter<ChatState> emit,
  ) {
    debugPrint('[ChatBloc] 🚫 Usuario expulsado del grupo ${event.chatId}');
    debugPrint('[ChatBloc] 📍 Sala actual: $_currentRoomId');
    
    // Emitir estado para que la UI pueda reaccionar (actualizar lista de chats)
    emit(UserKickedFromGroupState(chatId: event.chatId, chatName: event.chatName));
    
    // Si el usuario está en la sala del grupo del que fue expulsado, salir
    if (_currentRoomId == event.chatId) {
      debugPrint('[ChatBloc] ✅ Usuario está en la sala expulsada, cerrando chat...');
      _chatRepository.leaveRoom(event.chatId);
      _currentRoomId = null;
      _messages.clear();
      _usersTyping.clear();
      emit(const ChatDisconnected());
    } else {
      debugPrint('[ChatBloc] ⚠️ Usuario no está en la sala expulsada actualmente');
    }
  }

  /// Usuario añadido a grupo
  void _onGroupUserAdded(
    GroupUserAdded event,
    Emitter<ChatState> emit,
  ) {
    debugPrint('[ChatBloc] ➕ Usuario añadido al grupo ${event.chatId}');
    // Emitir un estado específico para que la UI pueda reaccionar
    emit(GroupUserAddedState(chatId: event.chatId, chatName: event.chatName));
  }

  /// Participante expulsado de grupo
  void _onGroupParticipantKicked(
    GroupParticipantKicked event,
    Emitter<ChatState> emit,
  ) {
    debugPrint('[ChatBloc] 🚫 Participante expulsado del grupo ${event.chatId}');
    // Emitir un estado específico para que la UI pueda reaccionar
    emit(GroupParticipantKickedState(chatId: event.chatId, chatName: event.chatName));
  }

  /// Grupo eliminado
  void _onGroupDeleted(
    GroupDeleted event,
    Emitter<ChatState> emit,
  ) {
    debugPrint('[ChatBloc] 🗑️ Grupo ${event.chatId} eliminado');
    // Si el usuario está en la sala del grupo eliminado, salir
    if (_currentRoomId == event.chatId) {
      _chatRepository.leaveRoom(event.chatId);
      _currentRoomId = null;
      _messages.clear();
      _usersTyping.clear();
      emit(const ChatDisconnected());
    }
    emit(GroupDeletedState(chatId: event.chatId, chatName: event.chatName));
  }

  /// Amistad eliminada (chat directo eliminado)
  void _onFriendshipDeleted(
    FriendshipDeleted event,
    Emitter<ChatState> emit,
  ) {
    debugPrint('[ChatBloc] 🗑️ Amistad eliminada, chat ${event.chatId} eliminado por ${event.deletedByNickname}');
    debugPrint('[ChatBloc] 📍 Sala actual: $_currentRoomId, Chat eliminado: ${event.chatId}');
    
    // Si el usuario está en la sala del chat eliminado, salir y limpiar estado
    if (_currentRoomId == event.chatId) {
      debugPrint('[ChatBloc] ✅ Usuario está en la sala eliminada, limpiando estado...');
      _chatRepository.leaveRoom(event.chatId);
      _currentRoomId = null;
      _messages.clear();
      _usersTyping.clear();
    }
    
    // Siempre emitir FriendshipDeletedState para que la UI pueda reaccionar
    // incluso si el usuario no está actualmente en esa sala
    emit(FriendshipDeletedState(
      chatId: event.chatId,
      deletedBy: event.deletedBy,
      deletedByNickname: event.deletedByNickname,
    ));
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _userJoinedSubscription?.cancel();
    _userLeftSubscription?.cancel();
    _messageDeletedSubscription?.cancel();
    _messageEditedSubscription?.cancel();
    _userKickedSubscription?.cancel();
    _groupUserAddedSubscription?.cancel();
    _friendshipDeletedSubscription?.cancel();
    return super.close();
  }
}