import 'package:flutter/foundation.dart';
import '../../../chat/dominio/entities/message.dart';

/// Modelo de datos para Message con serialización JSON
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.roomId,
    required super.senderId,
    required super.senderName,
    super.senderPhoto,
    required super.content,
    super.type,
    required super.timestamp,
    super.readBy,
  });

  /// Crear desde JSON (recibido de Socket.IO)
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final senderPhoto = json['senderPhoto'] as String? ?? json['sender_photo'] as String?;
    if (kDebugMode) {
      debugPrint('[MessageModel] 📨 Parsing message from JSON');
      debugPrint('[MessageModel]   - senderId: ${json['senderId'] ?? json['sender_email']}');
      debugPrint('[MessageModel]   - senderName: ${json['senderName'] ?? json['sender_nickname']}');
      debugPrint('[MessageModel]   - senderPhoto: $senderPhoto');
      debugPrint('[MessageModel]   - Full JSON: $json');
    }
    
    return MessageModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String? ?? json['chat_id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? json['sender_email'] as String? ?? '',
      senderName: json['senderName'] as String? ?? json['sender_nickname'] as String? ?? json['senderId'] as String? ?? '',
      senderPhoto: senderPhoto,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      timestamp: DateTime.parse(json['timestamp'] as String? ?? json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      readBy: json['readBy'] != null
          ? List<String>.from(json['readBy'] as List)
          : [],
    );
  }

  /// Convertir a JSON (para enviar)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'readBy': readBy,
    };
  }

  /// Convertir a entidad de dominio
  Message toEntity() {
    return Message(
      id: id,
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      senderPhoto: senderPhoto,
      content: content,
      type: type,
      timestamp: timestamp,
      readBy: readBy,
    );
  }

  /// Crear modelo desde entidad de dominio
  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      roomId: message.roomId,
      senderId: message.senderId,
      senderName: message.senderName,
      senderPhoto: message.senderPhoto,
      content: message.content,
      type: message.type,
      timestamp: message.timestamp,
      readBy: message.readBy,
    );
  }

  @override
  MessageModel copyWith({
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
    return MessageModel(
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
}