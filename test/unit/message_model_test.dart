import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/chat/dominio/models/message_model.dart';

void main() {
  group('MessageModel', () {
    group('fromJson', () {
      test('should parse valid JSON data correctly', () {
        final jsonData = {
          'id': 'msg-1',
          'roomId': 'room-1',
          'senderId': 'user@example.com',
          'senderEmail': 'user@example.com',
          'senderName': 'Test User',
          'senderNickname': 'testuser',
          'senderPhoto': 'https://example.com/photo.jpg',
          'content': 'Hello, world!',
          'type': 'text',
          'timestamp': 1640000000000,
          'createdAt': 1640000000000,
          'readBy': ['user1@example.com', 'user2@example.com'],
          'deleted': false,
          'edited': false,
        };

        final message = MessageModel.fromJson(jsonData);

        expect(message.id, 'msg-1');
        expect(message.roomId, 'room-1');
        expect(message.senderId, 'user@example.com');
        expect(message.senderName, 'Test User');
        expect(message.senderPhoto, 'https://example.com/photo.jpg');
        expect(message.content, 'Hello, world!');
        expect(message.type, 'text');
        expect(message.readBy.length, 2);
        expect(message.deleted, false);
        expect(message.edited, false);
      });

      test('should handle timestamp as string', () {
        final jsonData = {
          'id': 'msg-2',
          'roomId': 'room-2',
          'senderId': 'user@example.com',
          'senderName': 'Test User',
          'content': 'Test message',
          'timestamp': '1640000000000',
        };

        final message = MessageModel.fromJson(jsonData);

        expect(message.id, 'msg-2');
        expect(message.timestamp, isA<DateTime>());
      });

      test('should handle timestamp as ISO string', () {
        final jsonData = {
          'id': 'msg-3',
          'roomId': 'room-3',
          'senderId': 'user@example.com',
          'senderName': 'Test User',
          'content': 'Test message',
          'timestamp': '2022-01-01T00:00:00Z',
        };

        final message = MessageModel.fromJson(jsonData);

        expect(message.id, 'msg-3');
        expect(message.timestamp, isA<DateTime>());
      });

      test('should handle deleted message', () {
        final jsonData = {
          'id': 'msg-4',
          'roomId': 'room-4',
          'senderId': 'user@example.com',
          'senderName': 'Test User',
          'content': 'Deleted message',
          'timestamp': 1640000000000,
          'deleted': true,
          'deletedAt': '2022-01-01T00:00:00Z',
        };

        final message = MessageModel.fromJson(jsonData);

        expect(message.deleted, true);
        expect(message.deletedAt, isNotNull);
      });

      test('should handle edited message', () {
        final jsonData = {
          'id': 'msg-5',
          'roomId': 'room-5',
          'senderId': 'user@example.com',
          'senderName': 'Test User',
          'content': 'Edited message',
          'timestamp': 1640000000000,
          'edited': true,
          'editedAt': '2022-01-01T00:00:00Z',
        };

        final message = MessageModel.fromJson(jsonData);

        expect(message.edited, true);
        expect(message.editedAt, isNotNull);
      });

      test('should handle null values correctly', () {
        final jsonData = {
          'id': 'msg-6',
          'roomId': 'room-6',
          'senderId': 'user@example.com',
          'senderName': 'Test User',
          'content': 'Test message',
          'timestamp': 1640000000000,
        };

        final message = MessageModel.fromJson(jsonData);

        expect(message.senderPhoto, isNull);
        expect(message.readBy, isEmpty);
        expect(message.deleted, false);
        expect(message.edited, false);
      });

      test('should use chatId as roomId if roomId is missing', () {
        final jsonData = {
          'id': 'msg-7',
          'chatId': 'chat-7',
          'senderId': 'user@example.com',
          'senderName': 'Test User',
          'content': 'Test message',
          'timestamp': 1640000000000,
        };

        final message = MessageModel.fromJson(jsonData);

        expect(message.roomId, 'chat-7');
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly', () {
        final message = MessageModel(
          id: 'msg-1',
          roomId: 'room-1',
          senderId: 'user@example.com',
          senderName: 'Test User',
          senderPhoto: 'https://example.com/photo.jpg',
          content: 'Hello, world!',
          type: 'text',
          timestamp: DateTime.fromMillisecondsSinceEpoch(1640000000000),
          readBy: ['user1@example.com'],
          deleted: false,
          edited: false,
        );

        final json = message.toJson();

        expect(json['id'], 'msg-1');
        expect(json['roomId'], 'room-1');
        expect(json['senderId'], 'user@example.com');
        expect(json['senderName'], 'Test User');
        expect(json['content'], 'Hello, world!');
        expect(json['type'], 'text');
        expect(json['readBy'], ['user1@example.com']);
        expect(json['deleted'], false);
        expect(json['edited'], false);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = MessageModel(
          id: 'msg-1',
          roomId: 'room-1',
          senderId: 'user@example.com',
          senderName: 'Test User',
          content: 'Original message',
          timestamp: DateTime.now(),
        );

        final updated = original.copyWith(
          content: 'Updated message',
          edited: true,
        );

        expect(updated.content, 'Updated message');
        expect(updated.edited, true);
        expect(updated.id, original.id);
        expect(updated.roomId, original.roomId);
      });
    });
  });
}

