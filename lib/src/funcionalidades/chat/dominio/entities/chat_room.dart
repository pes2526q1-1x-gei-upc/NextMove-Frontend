import 'package:equatable/equatable.dart';

class ChatRoom extends Equatable {
  final String id;
  final String name;
  final String type; // 'direct' o 'group'
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;

  const ChatRoom({
    required this.id,
    required this.name,
    required this.type,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.createdAt,
  });

  bool get isDirect => type == 'direct';

  bool get isGroup => type == 'group';

  int get participantCount => participantIds.length;

  bool isParticipant(String userId) {
    return participantIds.contains(userId);
  }

  ChatRoom copyWith({
    String? id,
    String? name,
    String? type,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    DateTime? createdAt,
  }) {
    return ChatRoom(
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

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        participantIds,
        lastMessage,
        lastMessageTime,
        unreadCount,
        createdAt,
      ];

  @override
  String toString() {
    return 'ChatRoom(id: $id, name: $name, type: $type, participants: ${participantIds.length})';
  }
}