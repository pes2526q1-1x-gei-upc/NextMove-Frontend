const String getOrCreateDirectChatQuery = r'''
  query GetOrCreateDirectChat($userEmail: String!) {
    getOrCreateDirectChat(userEmail: $userEmail) {
      id
      type
      name
    }
  }
''';

const String myChatsQuery = r'''
  query MyChats {
    myChats {
      id
      type
      name
      description
      lastMessage {
        content
        sender
        timestamp
      }
      createdAt
      updatedAt
    }
  }
''';

const String chatMessagesQuery = r'''
  query ChatMessages($chatId: ID!, $limit: Int, $offset: Int) {
    chatMessages(chatId: $chatId, limit: $limit, offset: $offset) {
      id
      chatId
      senderEmail
      senderNickname
      senderPhoto
      content
      type
      createdAt
    }
  }
''';