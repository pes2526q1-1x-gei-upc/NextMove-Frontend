import 'package:equatable/equatable.dart';

/// Entidad de dominio para un mensaje de chat
class Message extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderPhoto;
  final String content;
  final String type;
  final DateTime timestamp;
  final List<String> readBy;

  const Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderPhoto,
    required this.content,
    this.type = 'text',
    required this.timestamp,
    this.readBy = const [],
  });

  /// Verificar si el mensaje fue leído por un usuario específico
  bool isReadBy(String userId) {
    return readBy.contains(userId);
  }

  /// Verificar si el usuario actual es el remitente
  bool isSentByMe(String currentUserId) {
    return senderId == currentUserId;
  }

  /// Copiar con nuevos valores
  Message copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderName,
    String? senderPhoto,
    String? content,
    String? type,
    DateTime? timestamp,
    List<String>? readBy,
  }) {
    return Message(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhoto: senderPhoto ?? this.senderPhoto,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      readBy: readBy ?? this.readBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        senderId,
        senderName,
        senderPhoto,
        content,
        type,
        timestamp,
        readBy,
      ];

  @override
  String toString() {
    return 'Message(id: $id, sender: $senderName, content: $content, timestamp: $timestamp)';
  }
}