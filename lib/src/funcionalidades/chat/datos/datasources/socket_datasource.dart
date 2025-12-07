import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../../config/socket_config.dart';
import '../models/message_model.dart';

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

  bool _listenersConfigured = false;
  SocketDataSource();

  /// Streams públicos para escuchar eventos
  Stream<MessageModel> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get userJoinedStream =>
      _userJoinedController.stream;
  Stream<Map<String, dynamic>> get userLeftStream =>
      _userLeftController.stream;
  Stream<Map<String, dynamic>> get roomJoinedStream =>
      _roomJoinedController.stream;

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

  /// Limpiar recursos
  void dispose() {
    _messageController.close();
    _typingController.close();
    _userJoinedController.close();
    _userLeftController.close();
    _roomJoinedController.close();
  }
}