import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketConfig {
  static io.Socket? _socket;
  static String? _currentUserId;

  static io.Socket? get socket => _socket;
  static bool get isConnected => _socket?.connected ?? false;

  static Future<void> connect(String firebaseToken, String userId) async {
    if (_socket != null && _socket!.connected) {
      if (_currentUserId != userId) {
        debugPrint(
          '[SocketIO] Usuario cambió de $_currentUserId a $userId, desconectando socket anterior...',
        );
        disconnect();
      } else {
        debugPrint(
          '[SocketIO] Ya existe una conexión activa para el mismo usuario',
        );
        return;
      }
    }

    _currentUserId = userId;
    final serverUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';

    debugPrint('[SocketIO] Conectando a: $serverUrl');
    debugPrint('[SocketIO] User ID: $userId');

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(999)
          .setTimeout(20000)
          .setAuth({'token': firebaseToken})
          .build(),
    );

    _setupEventHandlers();
  }

  static Function()? _onReconnectCallback;

  static void setReconnectCallback(Function() callback) {
    _onReconnectCallback = callback;
  }

  static void _setupEventHandlers() {
    _socket?.onConnect((_) {
      debugPrint('[SocketIO] Conectado exitosamente');
      debugPrint('[SocketIO] Socket ID: ${_socket?.id}');
    });

    _socket?.on('connection:success', (data) {
      debugPrint('[SocketIO] Autenticación exitosa');
      debugPrint('[SocketIO] Data: $data');
    });

    _socket?.onConnectError((error) {
      debugPrint('[SocketIO] Error de conexión: $error');
    });

    _socket?.onDisconnect((reason) {
      debugPrint('[SocketIO] Desconectado: $reason');
    });

    _socket?.onReconnect((attempt) {
      debugPrint('[SocketIO] Reconectado exitosamente (intento $attempt)');
      if (_onReconnectCallback != null) {
        _onReconnectCallback!();
      }
    });

    _socket?.on('error', (data) {
      debugPrint('[SocketIO] Error del servidor: $data');
    });

    _socket?.on('pong', (data) {
      debugPrint('[SocketIO] Pong recibido (evento personalizado): $data');
    });
  }

  static void disconnect() {
    debugPrint('[SocketIO] Desconectando...');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentUserId = null;
  }

  static String? get currentUserId => _currentUserId;
}
