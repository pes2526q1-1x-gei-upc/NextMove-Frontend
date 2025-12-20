import '../entities/chat_room.dart';

/// Modelo de datos para ChatRoom con serialización JSON
class ChatRoomModel extends ChatRoom {
  const ChatRoomModel({
    required super.id,
    required super.name,
    required super.type,
    required super.participantIds,
    super.lastMessage,
    super.lastMessageTime,
    super.unreadCount,
    required super.createdAt,
  });

  /// Crear desde JSON
  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      participantIds: List<String>.from(json['participantIds'] as List),
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convertir a entidad de dominio
  ChatRoom toEntity() {
    return ChatRoom(
      id: id,
      name: name,
      type: type,
      participantIds: participantIds,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      createdAt: createdAt,
    );
  }

  /// Crear modelo desde entidad de dominio
  factory ChatRoomModel.fromEntity(ChatRoom room) {
    return ChatRoomModel(
      id: room.id,
      name: room.name,
      type: room.type,
      participantIds: room.participantIds,
      lastMessage: room.lastMessage,
      lastMessageTime: room.lastMessageTime,
      unreadCount: room.unreadCount,
      createdAt: room.createdAt,
    );
  }

  @override
  ChatRoomModel copyWith({
    String? id,
    String? name,
    String? type,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    DateTime? createdAt,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}