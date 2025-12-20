import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import '../../../../../config/socket_config.dart';
import '../../dominio/models/message_model.dart';

/// DataSource para comunicación en tiempo real con Socket.IO
class SocketDataSource {
  final StreamController<MessageModel> _messageController =
      StreamController<MessageModel>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _userJoinedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _userLeftController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _roomJoinedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _messageDeletedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<MessageModel> _messageEditedController =
      StreamController<MessageModel>.broadcast();

  bool _listenersConfigured = false;
  SocketDataSource();

  GraphQLClient get client => GraphQLConfig.client.value;

  /// Streams públicos para escuchar eventos
  Stream<MessageModel> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get userJoinedStream =>
      _userJoinedController.stream;
  Stream<Map<String, dynamic>> get userLeftStream =>
      _userLeftController.stream;
  Stream<Map<String, dynamic>> get roomJoinedStream =>
      _roomJoinedController.stream;
  Stream<Map<String, dynamic>> get messageDeletedStream =>
      _messageDeletedController.stream;
  Stream<MessageModel> get messageEditedStream =>
      _messageEditedController.stream;

  /// Configurar listeners de Socket.IO
  void setupSocketListeners() {

    if (_listenersConfigured) {
      debugPrint('[SocketDataSource] Listeners ya configurados');
      return;
    }

    final socket = SocketConfig.socket;
    if (socket == null) {
      debugPrint('[SocketDataSource] Socket no inicializado');
      return;
    }

    // Escuchar nuevos mensajes
    debugPrint('[SocketDataSource] 🔧 Configurando listeners...');

    socket.on('message:new', (data) {
      debugPrint('[SocketDataSource] 💬 RAW DATA: $data');
      try {
        final message = MessageModel.fromJson(data as Map<String, dynamic>);
        _messageController.add(message);
        debugPrint('[SocketDataSource] ✅ Mensaje procesado');
      } catch (e) {
        debugPrint('[SocketDataSource] ❌ Error procesando mensaje: $e');
      }
    });

    // Escuchar usuarios escribiendo
    socket.on('typing:user', (data) {
      debugPrint('[SocketDataSource] ⌨️ Usuario escribiendo: $data');
      _typingController.add(data as Map<String, dynamic>);
    });

    socket.on('typing:stop', (data) {
      debugPrint('[SocketDataSource] ⌨️ Usuario dejó de escribir: $data');
      _typingController.add({
        ...data as Map<String, dynamic>,
        'stopped': true,
      });
    });

    // Escuchar usuarios uniéndose/saliendo
    socket.on('user:joined', (data) {
      debugPrint('[SocketDataSource] 👤 Usuario se unió: $data');
      _userJoinedController.add(data as Map<String, dynamic>);
    });

    socket.on('user:left', (data) {
      debugPrint('[SocketDataSource] 👋 Usuario salió: $data');
      _userLeftController.add(data as Map<String, dynamic>);
    });

    socket.on('user:disconnected', (data) {
      debugPrint('[SocketDataSource] 🔌 Usuario desconectado: $data');
      _userLeftController.add(data as Map<String, dynamic>);
    });

    // Confirmación de unirse a sala
    socket.on('room:joined', (data) {
      debugPrint('[SocketDataSource] ✅ Te uniste a sala: $data');
      _roomJoinedController.add(data as Map<String, dynamic>);
    });

    socket.on('room:left', (data) {
      debugPrint('[SocketDataSource] 👋 Saliste de sala: $data');
    });

    // Mensaje leído
    socket.on('message:read:confirmed', (data) {
      debugPrint('[SocketDataSource] ✓ Mensaje leído: $data');
    });

    // Mensaje eliminado
    socket.on('message:deleted', (data) {
      debugPrint('[SocketDataSource] 🗑️ Mensaje eliminado: $data');
      _messageDeletedController.add(data as Map<String, dynamic>);
    });

    // Mensaje editado
    socket.on('message:edited', (data) {
      debugPrint('[SocketDataSource] ✏️ Mensaje editado: $data');
      try {
        final message = MessageModel.fromJson(data as Map<String, dynamic>);
        _messageEditedController.add(message);
      } catch (e) {
        debugPrint('[SocketDataSource] ❌ Error procesando mensaje editado: $e');
      }
    });

    _listenersConfigured = true;
    debugPrint('[SocketDataSource] Listeners configurados');
  }

  /// Unirse a una sala de chat
  Future<void> joinRoom(String roomId) async {
    final socket = SocketConfig.socket;
    if (socket == null || !socket.connected) {
      throw Exception('Socket no conectado');
    }

    debugPrint('[SocketDataSource] 📥 Uniéndose a sala: $roomId');
    socket.emit('join:room', {'roomId': roomId});
  }

  /// Salir de una sala de chat
  Future<void> leaveRoom(String roomId) async {
    final socket = SocketConfig.socket;
    if (socket == null || !socket.connected) {
      throw Exception('Socket no conectado');
    }

    debugPrint('[SocketDataSource] 📤 Saliendo de sala: $roomId');
    socket.emit('leave:room', {'roomId': roomId});
  }

  /// Enviar mensaje a una sala
  Future<void> sendMessage({
    required String roomId,
    required String content,
    String type = 'text',
  }) async {
    final socket = SocketConfig.socket;
    if (socket == null || !socket.connected) {
      throw Exception('Socket no conectado');
    }

    debugPrint('[SocketDataSource] 💬 Enviando mensaje a sala $roomId');
    socket.emit('message:send', {
      'roomId': roomId,
      'content': content,
      'type': type,
    });
  }

  /// Indicar que el usuario está escribiendo
  void startTyping(String roomId) {
    final socket = SocketConfig.socket;
    if (socket == null || !socket.connected) return;

    socket.emit('typing:start', {'roomId': roomId});
  }

  /// Indicar que el usuario dejó de escribir
  void stopTyping(String roomId) {
    final socket = SocketConfig.socket;
    if (socket == null || !socket.connected) return;

    socket.emit('typing:stop', {'roomId': roomId});
  }

  /// Marcar mensaje como leído
  Future<void> markMessageAsRead({
    required String messageId,
    required String roomId,
  }) async {
    final socket = SocketConfig.socket;
    if (socket == null || !socket.connected) return;

    socket.emit('message:read', {
      'messageId': messageId,
      'roomId': roomId,
    });
  }

  /// Obtener usuarios en una sala
  Future<void> getRoomUsers(String roomId) async {
    final socket = SocketConfig.socket;
    if (socket == null || !socket.connected) {
      throw Exception('Socket no conectado');
    }

    socket.emit('room:users:get', {'roomId': roomId});
  }

  /// Eliminar mensaje
  Future<void> deleteMessage({
    required String messageId,
    required String roomId,
  }) async {
    final socket = SocketConfig.socket;
    if (socket == null || !socket.connected) {
      throw Exception('Socket no conectado');
    }

    debugPrint('[SocketDataSource] 🗑️ Eliminando mensaje $messageId');
    socket.emit('message:delete', {
      'messageId': messageId,
      'roomId': roomId,
    });
  }

  /// Editar mensaje
  Future<void> editMessage({
    required String messageId,
    required String roomId,
    required String newContent,
  }) async {
    final socket = SocketConfig.socket;
    if (socket == null || !socket.connected) {
      throw Exception('Socket no conectado');
    }

    debugPrint('[SocketDataSource] ✏️ Editando mensaje $messageId');
    socket.emit('message:edit', {
      'messageId': messageId,
      'roomId': roomId,
      'content': newContent,
    });
  }

  /// Limpiar recursos
  void dispose() {
    _messageController.close();
    _typingController.close();
    _userJoinedController.close();
    _userLeftController.close();
    _roomJoinedController.close();
    _messageDeletedController.close();
    _messageEditedController.close();
  }
}