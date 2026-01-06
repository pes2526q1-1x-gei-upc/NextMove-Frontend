import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/funcionalidades/chat/datos/dataproviders/socket_datasource.dart';
import 'package:nextmove_app/src/funcionalidades/chat/datos/repositories/chat_repository.dart';
import 'package:nextmove_app/src/funcionalidades/chat/dominio/models/message_model.dart';

class MockSocketDataSource extends Mock implements SocketDataSource {}

void main() {
  late MockSocketDataSource mockSocketDataSource;
  late ChatRepository repository;

  setUp(() {
    mockSocketDataSource = MockSocketDataSource();
    repository = ChatRepository(mockSocketDataSource);
  });

  tearDown(() {
    reset(mockSocketDataSource);
  });

  test('messageStream should map MessageModel to Message entity', () async {
    final controller = StreamController<MessageModel>();
    final messageModel = MessageModel(
      id: '1',
      roomId: 'room-1',
      senderId: 'sender',
      senderName: 'Sender',
      content: 'hello',
      timestamp: DateTime.now(),
      readBy: const [],
      deleted: false,
      edited: false,
    );

    when(() => mockSocketDataSource.messageStream)
        .thenAnswer((_) => controller.stream);

    final future = repository.messageStream.first;
    controller.add(messageModel);

    final entity = await future;
    expect(entity.id, equals('1'));
    expect(entity.content, equals('hello'));
    await controller.close();
  });

  test('joinRoom delegates to socket data source', () async {
    when(() => mockSocketDataSource.joinRoom(any()))
        .thenAnswer((_) async {});

    await repository.joinRoom('room-123');

    verify(() => mockSocketDataSource.joinRoom('room-123')).called(1);
  });

  test('sendMessage delegates with defaults', () async {
    when(() => mockSocketDataSource.sendMessage(
          roomId: any(named: 'roomId'),
          content: any(named: 'content'),
          type: any(named: 'type'),
        )).thenAnswer((_) async {});

    await repository.sendMessage(roomId: 'room-1', content: 'hola');

    verify(() => mockSocketDataSource.sendMessage(
          roomId: 'room-1',
          content: 'hola',
          type: 'text',
        )).called(1);
  });

  test('typing helpers delegate to data source', () {
    when(() => mockSocketDataSource.startTyping(any())).thenReturn(null);
    when(() => mockSocketDataSource.stopTyping(any())).thenReturn(null);

    repository.startTyping('room-1');
    repository.stopTyping('room-1');

    verify(() => mockSocketDataSource.startTyping('room-1')).called(1);
    verify(() => mockSocketDataSource.stopTyping('room-1')).called(1);
  });

  test('markMessageAsRead delegates to data source', () async {
    when(() => mockSocketDataSource.markMessageAsRead(
          messageId: any(named: 'messageId'),
          roomId: any(named: 'roomId'),
        )).thenAnswer((_) async {});

    await repository.markMessageAsRead(messageId: 'm1', roomId: 'room-1');

    verify(() => mockSocketDataSource.markMessageAsRead(
          messageId: 'm1',
          roomId: 'room-1',
        )).called(1);
  });
}
