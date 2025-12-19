import '../../../dominio/entities/message.dart';
import '../../../dominio/entities/chat_room.dart';

/// Repositorio abstracto para operaciones de chat
/// Define el contrato que debe cumplir la implementación
abstract class ChatRepository {
  /// Stream de mensajes nuevos
  Stream<Message> get messageStream;

  /// Stream de eventos de typing
  Stream<Map<String, dynamic>> get typingStream;

  /// Stream de usuarios uniéndose
  Stream<Map<String, dynamic>> get userJoinedStream;

  /// Stream de usuarios saliendo
  Stream<Map<String, dynamic>> get userLeftStream;

  /// Unirse a una sala de chat
  Future<void> joinRoom(String roomId);

  /// Salir de una sala de chat
  Future<void> leaveRoom(String roomId);

  /// Enviar un mensaje
  Future<void> sendMessage({
    required String roomId,
    required String content,
    String type,
  });

  /// Iniciar indicador de typing
  void startTyping(String roomId);

  /// Detener indicador de typing
  void stopTyping(String roomId);

  /// Marcar mensaje como leído
  Future<void> markMessageAsRead({
    required String messageId,
    required String roomId,
  });

  /// Obtener usuarios en una sala
  Future<void> getRoomUsers(String roomId);

  /// Obtener lista de salas de chat del usuario
  /// TODO: Implementar cuando tengas el endpoint GraphQL
  Future<List<ChatRoom>> getUserChatRooms();

  /// Obtener historial de mensajes de una sala
  /// TODO: Implementar cuando tengas el endpoint GraphQL
  Future<List<Message>> getRoomMessages(String roomId, {int limit = 50});
}