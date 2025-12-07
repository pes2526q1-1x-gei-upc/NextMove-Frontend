import '../../dominio/entities/message.dart';
import '../../dominio/entities/chat_room.dart';
import '../../dominio/repositories/chat_repository.dart';
import '../datasources/socket_datasource.dart';

/// Implementación concreta del ChatRepository
/// Utiliza SocketDataSource para comunicación en tiempo real
class ChatRepositoryImpl implements ChatRepository {
  final SocketDataSource _socketDataSource;

  ChatRepositoryImpl(this._socketDataSource);

  @override
  Stream<Message> get messageStream =>
      _socketDataSource.messageStream.map((model) => model.toEntity());

  @override
  Stream<Map<String, dynamic>> get typingStream =>
      _socketDataSource.typingStream;

  @override
  Stream<Map<String, dynamic>> get userJoinedStream =>
      _socketDataSource.userJoinedStream;

  @override
  Stream<Map<String, dynamic>> get userLeftStream =>
      _socketDataSource.userLeftStream;

  @override
  Future<void> joinRoom(String roomId) async {
    return await _socketDataSource.joinRoom(roomId);
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    return await _socketDataSource.leaveRoom(roomId);
  }

  @override
  Future<void> sendMessage({
    required String roomId,
    required String content,
    String type = 'text',
  }) async {
    return await _socketDataSource.sendMessage(
      roomId: roomId,
      content: content,
      type: type,
    );
  }

  @override
  void startTyping(String roomId) {
    _socketDataSource.startTyping(roomId);
  }

  @override
  void stopTyping(String roomId) {
    _socketDataSource.stopTyping(roomId);
  }

  @override
  Future<void> markMessageAsRead({
    required String messageId,
    required String roomId,
  }) async {
    return await _socketDataSource.markMessageAsRead(
      messageId: messageId,
      roomId: roomId,
    );
  }

  @override
  Future<void> getRoomUsers(String roomId) async {
    return await _socketDataSource.getRoomUsers(roomId);
  }

  @override
  Future<List<ChatRoom>> getUserChatRooms() async {
    // TODO: Implementar cuando tengas el endpoint GraphQL
    // Por ahora retornar lista vacía o salas mock
    return [];
  }

  @override
  Future<List<Message>> getRoomMessages(String roomId, {int limit = 50}) async {
    // TODO: Implementar cuando tengas el endpoint GraphQL
    // Por ahora retornar lista vacía
    return [];
  }
}