import 'package:flutter/foundation.dart';
import '../entities/message.dart';

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
    super.deleted,
    super.deletedAt,
    super.edited,
    super.editedAt,
  });

  /// Helper para parsear fechas desde diferentes formatos
  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    
    // Si es un número (timestamp en milisegundos)
    if (value is int || value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    
    // Si es un String, intentar parsearlo
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        // Si falla, intentar como timestamp numérico en string
        try {
          final timestamp = int.parse(value);
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        } catch (e2) {
          if (kDebugMode) {
            debugPrint('[MessageModel] No se pudo parsear fecha: $value');
          }
          return DateTime.now();
        }
      }
    }
    
    return DateTime.now();
  }

  /// Crear desde JSON 
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final senderPhoto = json['senderPhoto'] as String? ?? json['sender_photo'] as String?;
    if (kDebugMode) {
      debugPrint('[MessageModel] Parsing message from JSON');
      debugPrint('[MessageModel]   - senderId: ${json['senderId'] ?? json['sender_email']}');
      debugPrint('[MessageModel]   - senderName: ${json['senderName'] ?? json['sender_nickname']}');
      debugPrint('[MessageModel]   - senderPhoto: $senderPhoto');
      debugPrint('[MessageModel]   - Full JSON: $json');
    }
    
    // Parsear timestamp desde diferentes campos y formatos
    final timestampValue = json['timestamp'] ?? json['createdAt'] ?? json['created_at'];
    final timestamp = _parseTimestamp(timestampValue);
    
    // Priorizar senderEmail sobre senderId porque senderId puede ser el UID de Firebase
    // pero necesitamos el email para comparar correctamente
    final senderEmail = json['senderEmail'] as String? ?? json['sender_email'] as String?;
    final senderId = senderEmail ?? json['senderId'] as String? ?? '';
    
    // Parsear deleted y deletedAt
    final deleted = json['deleted'] as bool? ?? false;
    final deletedAtValue = json['deletedAt'] as String? ?? json['deleted_at'] as String?;
    final deletedAt = deletedAtValue != null ? _parseTimestamp(deletedAtValue) : null;
    
    // Parsear edited y editedAt
    final edited = json['edited'] as bool? ?? false;
    final editedAtValue = json['editedAt'] as String? ?? json['edited_at'] as String?;
    final editedAt = editedAtValue != null ? _parseTimestamp(editedAtValue) : null;
    
    return MessageModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String? ?? json['chatId'] as String? ?? json['chat_id'] as String? ?? '',
      senderId: senderId, // Siempre usar el email como senderId para comparaciones
      senderName: json['senderName'] as String? ?? json['senderNickname'] as String? ?? json['sender_nickname'] as String? ?? senderEmail ?? '',
      senderPhoto: senderPhoto,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      timestamp: timestamp,
      readBy: json['readBy'] != null
          ? List<String>.from(json['readBy'] as List)
          : [],
      deleted: deleted,
      deletedAt: deletedAt,
      edited: edited,
      editedAt: editedAt,
    );
  }

  /// Convertir a JSON 
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
      'deleted': deleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'edited': edited,
      'editedAt': editedAt?.toIso8601String(),
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
      deleted: deleted,
      deletedAt: deletedAt,
      edited: edited,
      editedAt: editedAt,
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
      deleted: message.deleted,
      deletedAt: message.deletedAt,
      edited: message.edited,
      editedAt: message.editedAt,
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
    bool? deleted,
    DateTime? deletedAt,
    bool? edited,
    DateTime? editedAt,
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
      deleted: deleted ?? this.deleted,
      deletedAt: deletedAt ?? this.deletedAt,
      edited: edited ?? this.edited,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}