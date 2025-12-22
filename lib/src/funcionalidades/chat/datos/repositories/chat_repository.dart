import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import '../../dominio/entities/message.dart';
import '../../dominio/entities/chat_room.dart';
import '../../dominio/models/message_model.dart';
import '../dataproviders/socket_datasource.dart';

/// Repositorio para operaciones de chat
/// Utiliza SocketDataSource para comunicación en tiempo real
class ChatRepository {
  final SocketDataSource _socketDataSource;
  ChatRepository(this._socketDataSource);
  SocketDataSource get socketDataSource => _socketDataSource;

  /// Configurar listeners de Socket.IO
  void setupSocketListeners() {
    _socketDataSource.setupSocketListeners();
  }

  /// Resetear y reconfigurar listeners de Socket.IO (por ejemplo tras reconexión)
  void resetSocketListeners() {
    _socketDataSource.resetSocketListeners();
  }

  /// Stream de mensajes nuevos
  Stream<Message> get messageStream =>
      _socketDataSource.messageStream.map((model) => model.toEntity());

  /// Stream de eventos de typing
  Stream<Map<String, dynamic>> get typingStream =>
      _socketDataSource.typingStream;

  /// Stream de usuarios uniéndose
  Stream<Map<String, dynamic>> get userJoinedStream =>
      _socketDataSource.userJoinedStream;

  /// Stream de usuarios saliendo
  Stream<Map<String, dynamic>> get userLeftStream =>
      _socketDataSource.userLeftStream;

  /// Unirse a una sala de chat
  Future<void> joinRoom(String roomId) async {
    return await _socketDataSource.joinRoom(roomId);
  }

  /// Salir de una sala de chat
  Future<void> leaveRoom(String roomId) async {
    return await _socketDataSource.leaveRoom(roomId);
  }

  /// Enviar un mensaje
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

  /// Iniciar indicador de typing
  void startTyping(String roomId) {
    _socketDataSource.startTyping(roomId);
  }

  /// Detener indicador de typing
  void stopTyping(String roomId) {
    _socketDataSource.stopTyping(roomId);
  }

  /// Marcar mensaje como leído
  Future<void> markMessageAsRead({
    required String messageId,
    required String roomId,
  }) async {
    return await _socketDataSource.markMessageAsRead(
      messageId: messageId,
      roomId: roomId,
    );
  }

  /// Obtener usuarios en una sala
  Future<void> getRoomUsers(String roomId) async {
    return await _socketDataSource.getRoomUsers(roomId);
  }

  /// Eliminar mensaje
  Future<void> deleteMessage({
    required String messageId,
    required String roomId,
  }) async {
    return await _socketDataSource.deleteMessage(
      messageId: messageId,
      roomId: roomId,
    );
  }

  /// Editar mensaje
  Future<void> editMessage({
    required String messageId,
    required String roomId,
    required String newContent,
  }) async {
    return await _socketDataSource.editMessage(
      messageId: messageId,
      roomId: roomId,
      newContent: newContent,
    );
  }

  /// Obtener lista de salas de chat del usuario
  /// TODO: Implementar cuando tengas el endpoint GraphQL
  Future<List<ChatRoom>> getUserChatRooms() async {
    // TODO: Implementar cuando tengas el endpoint GraphQL
    // Por ahora retornar lista vacía o salas mock
    return [];
  }

  /// Obtener historial de mensajes de una sala
  Future<List<Message>> getRoomMessages(String roomId, {int limit = 50, int offset = 0}) async {
    try {
      final fireBaseUser = FirebaseAuth.instance.currentUser;
      if (fireBaseUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final token = await fireBaseUser.getIdToken();
      final authHeader = 'Bearer $token';

      final GraphQLClient client = GraphQLConfig.client.value;

      final QueryOptions options = QueryOptions(
        document: gql(chatMessagesQuery),
        variables: {
          'chatId': roomId,
          'limit': limit,
          'offset': offset,
        },
        fetchPolicy: FetchPolicy.networkOnly,
        context: Context().withEntry(
          HttpLinkHeaders(headers: {'Authorization': authHeader}),
        ),
      );

      if (kDebugMode) {
        debugPrint('[ChatRepository] 📥 Cargando mensajes históricos para chat: $roomId');
      }

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        if (kDebugMode) {
          debugPrint('[ChatRepository] ❌ Error en query: ${result.exception}');
        }
        throw Exception('Error al cargar mensajes: ${result.exception}');
      }

      final List<dynamic>? messagesData = result.data?['chatMessages'] as List<dynamic>?;

      if (messagesData == null || messagesData.isEmpty) {
        if (kDebugMode) {
          debugPrint('[ChatRepository] ✅ No hay mensajes históricos');
        }
        return [];
      }

      // Parsear cada mensaje y convertirlo a Message
      final List<Message> messages = messagesData.map((json) {
        // Mapear los campos de GraphQL al formato esperado por MessageModel
        // createdAt puede venir como String ISO8601 o como número (timestamp)
        final messageJson = {
          'id': json['id'] as String,
          'chatId': json['chatId'] as String? ?? roomId,
          'roomId': json['chatId'] as String? ?? roomId,
          'senderEmail': json['senderEmail'] as String?,
          'senderId': json['senderEmail'] as String?,
          'senderNickname': json['senderNickname'] as String?,
          'senderName': json['senderNickname'] as String?,
          'senderPhoto': json['senderPhoto'] as String?,
          'content': json['content'] as String,
          'type': json['type'] as String? ?? 'text',
          // createdAt puede ser String o número, MessageModel.fromJson lo manejará
          'createdAt': json['createdAt'],
          'timestamp': json['createdAt'],
          'deleted': json['deleted'] as bool? ?? false,
          'deletedAt': json['deletedAt'],
          'edited': json['edited'] as bool? ?? false,
          'editedAt': json['editedAt'],
        };

        final messageModel = MessageModel.fromJson(messageJson);
        return messageModel.toEntity();
      }).toList();

      if (kDebugMode) {
        debugPrint('[ChatRepository] ✅ Cargados ${messages.length} mensajes históricos');
      }

      // Ordenar mensajes por timestamp (más antiguos primero)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return messages;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ChatRepository] ❌ Error cargando mensajes: $e');
      }
      rethrow;
    }
  }
}
