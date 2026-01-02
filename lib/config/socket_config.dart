import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketConfig {
  static io.Socket? _socket;
  static String? _currentUserId;

  static io.Socket? get socket => _socket;
  static bool get isConnected => _socket?.connected ?? false;

  /// Inicializar conexión Socket.IO
  /// Requiere el token de Firebase para autenticación
  static Future<void> connect(String firebaseToken, String userId) async {
    // Si ya hay una conexión pero con un usuario diferente, desconectar primero
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
          .setReconnectionAttempts(999) // Intentos ilimitados
          .setTimeout(20000)
          .setAuth({'token': firebaseToken})
          .build(),
    );

    _setupEventHandlers();
  }

  // Callback para notificar reconexión
  static Function()? _onReconnectCallback;

  /// Configurar callback para reconexión
  static void setReconnectCallback(Function() callback) {
    _onReconnectCallback = callback;
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
      debugPrint('[SocketIO] 🔄 Reconectado exitosamente (intento $attempt)');
      // Notificar reconexión
      if (_onReconnectCallback != null) {
        _onReconnectCallback!();
      }
    });

    _socket?.on('error', (data) {
      debugPrint('[SocketIO] ⚠️ Error del servidor: $data');
    });

    // Nota: Este listener escucha un evento 'pong' personalizado, no el pong nativo del heartbeat
    // El heartbeat nativo de Socket.IO se maneja automáticamente y no emite eventos visibles
    _socket?.on('pong', (data) {
      debugPrint('[SocketIO] 🏓 Pong recibido (evento personalizado): $data');
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

  /// Enviar evento de ping personalizado (NO es el ping del heartbeat nativo)
  ///
  /// NOTA: Este método ya no se usa. Socket.IO maneja automáticamente el heartbeat
  /// mediante ping/pong nativo según la configuración del servidor (pingInterval/pingTimeout).
  /// El heartbeat nativo es transparente y no requiere código adicional.
  ///
  /// Si necesitas enviar un evento 'ping' personalizado por alguna razón específica,
  /// puedes usar este método, pero no ayuda al mantenimiento de la conexión.
  @Deprecated('Socket.IO maneja el heartbeat automáticamente. No es necesario.')
  static void ping() {
    if (_socket?.connected ?? false) {
      _socket?.emit('ping');
    }
  }

  /// Obtener el ID del usuario actual
  static String? get currentUserId => _currentUserId;
}
