import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/chat/dominio/models/chat_room_model.dart';

void main() {
  group('ChatRoomModel', () {
    group('fromJson', () {
      test('should parse valid JSON data correctly', () {
        final jsonData = {
          'id': 'room-1',
          'name': 'Test Room',
          'type': 'group',
          'participantIds': ['user1@example.com', 'user2@example.com'],
          'lastMessage': 'Last message text',
          'lastMessageTime': '2022-01-01T00:00:00Z',
          'unreadCount': 5,
          'createdAt': '2022-01-01T00:00:00Z',
        };

        final room = ChatRoomModel.fromJson(jsonData);

        expect(room.id, 'room-1');
        expect(room.name, 'Test Room');
        expect(room.type, 'group');
        expect(room.participantIds.length, 2);
        expect(room.lastMessage, 'Last message text');
        expect(room.unreadCount, 5);
        expect(room.createdAt, DateTime.parse('2022-01-01T00:00:00Z'));
      });

      test('should handle null values correctly', () {
        final jsonData = {
          'id': 'room-2',
          'name': 'Test Room 2',
          'type': 'direct',
          'participantIds': ['user1@example.com'],
          'createdAt': '2022-01-01T00:00:00Z',
        };

        final room = ChatRoomModel.fromJson(jsonData);

        expect(room.lastMessage, isNull);
        expect(room.lastMessageTime, isNull);
        expect(room.unreadCount, 0);
      });

      test('should handle empty participant list', () {
        final jsonData = {
          'id': 'room-3',
          'name': 'Empty Room',
          'type': 'group',
          'participantIds': [],
          'createdAt': '2022-01-01T00:00:00Z',
        };

        final room = ChatRoomModel.fromJson(jsonData);

        expect(room.participantIds, isEmpty);
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly', () {
        final room = ChatRoomModel(
          id: 'room-1',
          name: 'Test Room',
          type: 'group',
          participantIds: ['user1@example.com', 'user2@example.com'],
          lastMessage: 'Last message',
          lastMessageTime: DateTime.parse('2022-01-01T00:00:00Z'),
          unreadCount: 3,
          createdAt: DateTime.parse('2022-01-01T00:00:00Z'),
        );

        final json = room.toJson();

        expect(json['id'], 'room-1');
        expect(json['name'], 'Test Room');
        expect(json['type'], 'group');
        expect(json['participantIds'], ['user1@example.com', 'user2@example.com']);
        expect(json['lastMessage'], 'Last message');
        expect(json['unreadCount'], 3);
      });

      test('should handle null values in toJson', () {
        final room = ChatRoomModel(
          id: 'room-2',
          name: 'Test Room 2',
          type: 'direct',
          participantIds: ['user1@example.com'],
          createdAt: DateTime.parse('2022-01-01T00:00:00Z'),
        );

        final json = room.toJson();

        expect(json['lastMessage'], isNull);
        expect(json['lastMessageTime'], isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = ChatRoomModel(
          id: 'room-1',
          name: 'Original Room',
          type: 'group',
          participantIds: ['user1@example.com'],
          createdAt: DateTime.now(),
        );

        final updated = original.copyWith(
          name: 'Updated Room',
          unreadCount: 10,
        );

        expect(updated.name, 'Updated Room');
        expect(updated.unreadCount, 10);
        expect(updated.id, original.id);
        expect(updated.type, original.type);
      });
    });
  });
}

