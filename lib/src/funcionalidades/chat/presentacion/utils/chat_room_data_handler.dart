import '../../dominio/entities/message.dart';

class ChatRoomDataHandler {
  static Map<String, String>? getParticipantsMap(
    Map<String, dynamic>? data,
    String roomId,
  ) {
    if (data == null) return null;
    final chats = data['myChats'] as List<dynamic>? ?? [];
    final chat = chats.firstWhere((c) => c['id'] == roomId, orElse: () => null);
    if (chat == null) return null;

    final participants = chat['participants'] as List<dynamic>? ?? [];
    final map = <String, String>{};
    for (var p in participants) {
      final email = p['userEmail'] as String? ?? '';
      final nickname = p['nickname'] as String?;
      if (email.isNotEmpty) {
        map[email] = nickname ?? email.split('@').first;
      }
    }
    return map;
  }

  static String? getOtherUserPhoto(
    List<Message> messages,
    String currentUserEmail,
  ) {
    for (final message in messages) {
      if (!message.isSentByMe(currentUserEmail)) {
        return message.senderPhoto;
      }
    }
    return null;
  }

  static String getOtherNickname(
    List<Message> messages,
    String currentUserEmail,
    String defaultName,
  ) {
    for (final message in messages) {
      if (!message.isSentByMe(currentUserEmail)) {
        return message.senderName;
      }
    }
    return defaultName;
  }
}
