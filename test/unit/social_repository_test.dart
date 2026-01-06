import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/social/data/dataproviders/social_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/social/data/repositories/social_repository.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';

class MockSocialRemoteDataProvider extends Mock implements SocialRemoteDataProvider {}

void main() {
  late SocialRepository repository;
  late MockSocialRemoteDataProvider mockDataProvider;

  setUp(() {
    mockDataProvider = MockSocialRemoteDataProvider();
    repository = SocialRepository(remoteDataProvider: mockDataProvider);
  });

  group('SocialRepository', () {
    group('getFriends', () {
      test('should return list of friends when data provider succeeds', () async {
        final mockFriends = [
          UserEntity(
            email: 'friend1@example.com',
            apodo: 'friend1',
            nombreCompleto: 'Friend One',
            fechaNacimiento: DateTime.now(),
            fechaRegistro: DateTime.now(),
            numeroTelefono: 0,
            idiomaPreferido: 'Español',
            descripcion: '',
            modoPreferido: 'BIKE',
            photo: 'photo1.jpg',
          ),
          UserEntity(
            email: 'friend2@example.com',
            apodo: 'friend2',
            nombreCompleto: 'Friend Two',
            fechaNacimiento: DateTime.now(),
            fechaRegistro: DateTime.now(),
            numeroTelefono: 0,
            idiomaPreferido: 'Español',
            descripcion: '',
            modoPreferido: 'BIKE',
            photo: 'photo2.jpg',
          ),
        ];

        when(() => mockDataProvider.getFriends())
            .thenAnswer((_) async => mockFriends);

        final result = await repository.getFriends();

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (friends) {
            expect(friends.length, 2);
            expect(friends[0].apodo, 'friend1');
            expect(friends[1].apodo, 'friend2');
          },
        );
        verify(() => mockDataProvider.getFriends()).called(1);
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.getFriends())
            .thenThrow(ServerException('Server error'));

        final result = await repository.getFriends();

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            // SocialRepository usa e.toString(), no e.message
            expect((failure as ServerFailure).message, contains('ServerException'));
          },
          (_) => fail('Expected Left, got Right'),
        );
      });

      test('should return ServerFailure when other exception is thrown', () async {
        when(() => mockDataProvider.getFriends())
            .thenThrow(Exception('Generic error'));

        final result = await repository.getFriends();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('searchUsers', () {
      test('should return list of users when data provider succeeds', () async {
        final mockUsers = [
          UserEntity(
            email: 'user1@example.com',
            apodo: 'user1',
            nombreCompleto: 'User One',
            fechaNacimiento: DateTime.now(),
            fechaRegistro: DateTime.now(),
            numeroTelefono: 0,
            idiomaPreferido: 'Español',
            descripcion: '',
            modoPreferido: 'BIKE',
            photo: '',
          ),
        ];

        when(() => mockDataProvider.searchUsers('user1'))
            .thenAnswer((_) async => mockUsers);

        final result = await repository.searchUsers('user1');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (users) {
            expect(users.length, 1);
            expect(users[0].apodo, 'user1');
          },
        );
        verify(() => mockDataProvider.searchUsers('user1')).called(1);
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.searchUsers('test'))
            .thenThrow(ServerException('Server error'));

        final result = await repository.searchUsers('test');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('addFriend', () {
      test('should return Right(null) when data provider succeeds', () async {
        when(() => mockDataProvider.addFriend('friend1'))
            .thenAnswer((_) async => Future.value());

        final result = await repository.addFriend('friend1');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (_) {},
        );
        verify(() => mockDataProvider.addFriend('friend1')).called(1);
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.addFriend('friend1'))
            .thenThrow(ServerException('Server error'));

        final result = await repository.addFriend('friend1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('removeFriend', () {
      test('should return Right(null) when data provider succeeds', () async {
        when(() => mockDataProvider.removeFriend('friend1'))
            .thenAnswer((_) async => Future.value());

        final result = await repository.removeFriend('friend1');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (_) {},
        );
        verify(() => mockDataProvider.removeFriend('friend1')).called(1);
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.removeFriend('friend1'))
            .thenThrow(ServerException('Server error'));

        final result = await repository.removeFriend('friend1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('blockUser', () {
      test('should return Right(null) when data provider succeeds', () async {
        when(() => mockDataProvider.blockUser('user1'))
            .thenAnswer((_) async => Future.value());

        final result = await repository.blockUser('user1');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (_) {},
        );
        verify(() => mockDataProvider.blockUser('user1')).called(1);
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.blockUser('user1'))
            .thenThrow(ServerException('Server error'));

        final result = await repository.blockUser('user1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('getBlockedUsers', () {
      test('should return list of blocked users when data provider succeeds', () async {
        final mockBlockedUsers = [
          UserEntity(
            email: 'blocked1@example.com',
            apodo: 'blocked1',
            nombreCompleto: 'Blocked One',
            fechaNacimiento: DateTime.now(),
            fechaRegistro: DateTime.now(),
            numeroTelefono: 0,
            idiomaPreferido: 'Español',
            descripcion: '',
            modoPreferido: 'BIKE',
            photo: '',
          ),
        ];

        when(() => mockDataProvider.getBlockedUsers())
            .thenAnswer((_) async => mockBlockedUsers);

        final result = await repository.getBlockedUsers();

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (blockedUsers) {
            expect(blockedUsers.length, 1);
            expect(blockedUsers[0].apodo, 'blocked1');
          },
        );
        verify(() => mockDataProvider.getBlockedUsers()).called(1);
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.getBlockedUsers())
            .thenThrow(ServerException('Server error'));

        final result = await repository.getBlockedUsers();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('unblockUser', () {
      test('should return Right(null) when data provider succeeds', () async {
        when(() => mockDataProvider.unblockUser('user1'))
            .thenAnswer((_) async => Future.value());

        final result = await repository.unblockUser('user1');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (_) {},
        );
        verify(() => mockDataProvider.unblockUser('user1')).called(1);
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.unblockUser('user1'))
            .thenThrow(ServerException('Server error'));

        final result = await repository.unblockUser('user1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });
  });
}
