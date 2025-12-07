import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketConfig {
  static IO.Socket? _socket;
  static String? _currentUserId;

  static IO.Socket? get socket => _socket;
  static bool get isConnected => _socket?.connected ?? false;

  /// Inicializar conexión Socket.IO
  /// Requiere el token de Firebase para autenticación
  static Future<void> connect(String firebaseToken, String userId) async {
    if (_socket != null && _socket!.connected) {
      debugPrint('[SocketIO] Ya existe una conexión activa');
      return;
    }

    _currentUserId = userId;
    final serverUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';

    debugPrint('[SocketIO] Conectando a: $serverUrl');
    debugPrint('[SocketIO] User ID: $userId');

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(5)
          .setAuth({'token': firebaseToken})
          .build(),
    );

    _setupEventHandlers();
  }

  /// Configurar listeners básicos de conexión
  static void _setupEventHandlers() {
    _socket?.onConnect((_) {
      debugPrint('[SocketIO] ✅ Conectado exitosamente');
      debugPrint('[SocketIO] Socket ID: ${_socket?.id}');
    });

    _socket?.on('connection:success', (data) {
      debugPrint('[SocketIO] 🎉 Autenticación exitosa');
      debugPrint('[SocketIO] Data: $data');
    });

    _socket?.onConnectError((error) {
      debugPrint('[SocketIO] ❌ Error de conexión: $error');
    });

    _socket?.onDisconnect((reason) {
      debugPrint('[SocketIO] 🔌 Desconectado: $reason');
    });

    _socket?.onReconnect((attempt) {
      debugPrint('[SocketIO] 🔄 Reconectando (intento $attempt)');
    });

    _socket?.on('error', (data) {
      debugPrint('[SocketIO] ⚠️ Error del servidor: $data');
    });

    _socket?.on('pong', (data) {
      debugPrint('[SocketIO] 🏓 Pong recibido: $data');
    });
  }

  /// Desconectar y limpiar recursos
  static void disconnect() {
    debugPrint('[SocketIO] Desconectando...');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentUserId = null;
  }

  /// Enviar evento de ping para verificar conexión
  static void ping() {
    if (_socket?.connected ?? false) {
      _socket?.emit('ping');
    }
  }

  /// Obtener el ID del usuario actual
  static String? get currentUserId => _currentUserId;
}