class ChatListDataHandler {
  /// Procesa los datos de chats y amigos para obtener la lista final a mostrar
  static List<Map<String, dynamic>> getProcessedChatItems({
    required List<dynamic> allChats,
    required List<dynamic>? friendsData,
    required String? currentUserEmail,
    required bool showFriends,
    required String searchQuery,
  }) {
    final friendsNicknames =
        friendsData
            ?.map((f) => f['name'] as String? ?? '')
            .where((n) => n.isNotEmpty)
            .toList() ??
        [];

    final directChats = allChats.where((chat) {
      if (chat['type'] != 'direct' || chat['lastMessage'] == null) {
        return false;
      }
      if (friendsNicknames.isNotEmpty && currentUserEmail != null) {
        final participants = chat['participants'] as List<dynamic>? ?? [];
        try {
          final other = participants.firstWhere(
            (p) => p['userEmail'] != currentUserEmail,
          );
          if (!friendsNicknames.contains(other['nickname'])) {
            return false;
          }
        } catch (_) {
          // Si no encontramos al otro participante, no mostramos el chat en la lista de amigos
          return false;
        }
      }
      return true;
    }).toList();

    final groupChats = allChats
        .where((chat) => chat['type'] == 'group')
        .toList();
    final chatsToShow = showFriends ? directChats : groupChats;

    final chatItems = chatsToShow.map((chat) {
      if (chat['type'] == 'direct' && currentUserEmail != null) {
        final participants = chat['participants'] as List<dynamic>? ?? [];
        var other = participants.isNotEmpty ? participants.first : null;
        try {
          other = participants.firstWhere(
            (p) => p['userEmail'] != currentUserEmail,
          );
        } catch (_) {}

        return {
          'name': chat['name'] ?? other?['nickname'] ?? 'Usuario',
          'photo': other?['photoUrl'],
          'chatId': chat['id'],
          'email': other?['userEmail'],
          'type': 'direct',
          'lastMessage': chat['lastMessage'],
        };
      } else {
        return {
          'name': chat['name'] ?? 'Grupo',
          'photo': chat['photo'],
          'chatId': chat['id'],
          'email': null,
          'type': 'group',
          'description': chat['description'],
          'lastMessage': chat['lastMessage'],
        };
      }
    }).toList();

    // Añadir amigos que no tienen chat aún si estamos buscando
    if (showFriends && searchQuery.isNotEmpty && friendsData != null) {
      for (final friend in friendsData) {
        final friendName = friend['name'] ?? '';
        if (!chatItems.any((c) => c['name'] == friendName)) {
          chatItems.add({
            'name': friendName,
            'photo': friend['photo'],
            'chatId': null,
            'email': friend['email'],
            'type': 'direct',
            'lastMessage': null,
          });
        }
      }
    }

    // Filtrar por búsqueda
    if (searchQuery.isEmpty) {
      return chatItems;
    }

    return chatItems
        .where(
          (item) => (item['name'] as String).toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  /// Extrae los IDs de los grupos de una lista de chats
  static Set<String> getGroupIds(List<dynamic> chats) {
    return chats
        .where((chat) => chat['type'] == 'group')
        .map((chat) => chat['id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }
}
