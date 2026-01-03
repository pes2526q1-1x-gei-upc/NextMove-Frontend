import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/data/dataproviders/challenges_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/data/repositories/challenges_repository.dart';

class MockChallengesRemoteDataProvider extends Mock implements ChallengesRemoteDataProvider {}

void main() {
  late ChallengesRepository repository;
  late MockChallengesRemoteDataProvider mockDataProvider;

  setUp(() {
    mockDataProvider = MockChallengesRemoteDataProvider();
    repository = ChallengesRepository(mockDataProvider);
  });

  group('ChallengesRepository', () {
    test('should return list of challenges when data provider succeeds', () async {
      final mockData = [
        {
          'id': '1',
          'company': {
            'name': 'Company 1',
            'email': 'company1@test.com',
            'url': 'https://company1.com',
            'description': 'First test company',
            'logo_url': 'https://company1.com/logo.png',
          },
          'description': 'Test challenge 1',
          'distance': 10.0,
          'ending_date': '1740009600000',
          'name': 'Challenge 1',
          'points': 100,
          'starting_date': '1738368000000',
        },
        {
          'id': '2',
          'company': {
            'name': 'Company 2',
            'email': 'company2@test.com',
            'url': 'https://company2.com',
            'description': 'Second test company',
            'logo_url': null,
          },
          'description': 'Test challenge 2',
          'distance': 5.0,
          'ending_date': '1740009600000',
          'name': 'Challenge 2',
          'points': 50,
          'starting_date': '1738368000000',
        },
      ];
      final mockEnrolledNames = ['Challenge 1'];
      when(() => mockDataProvider.getAllChallenges()).thenAnswer((_) async => mockData);
      when(() => mockDataProvider.getEnrolledChallengesNames()).thenAnswer((_) async => mockEnrolledNames);

      final result = await repository.getallChallenges();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right, got Left'),
        (challenges) {
          expect(challenges, isNotNull);
          expect(challenges!.length, 2);
          expect(challenges[0].name, 'Challenge 1');
          expect(challenges[0].isEnrolled, true);
          expect(challenges[1].name, 'Challenge 2');
          expect(challenges[1].isEnrolled, false);
        },
      );
      verify(() => mockDataProvider.getAllChallenges()).called(1);
      verify(() => mockDataProvider.getEnrolledChallengesNames()).called(1);
    });

    test('should return ServerFailure when ServerException is thrown', () async {
      when(() => mockDataProvider.getAllChallenges()).thenThrow(ServerException('Server error'));
      when(() => mockDataProvider.getEnrolledChallengesNames()).thenAnswer((_) async => []);

      final result = await repository.getallChallenges();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (challenges) => fail('Expected Left, got Right'),
      );
    });

    test('should return ConnectionFailure when ConnectionException is thrown', () async {
      when(() => mockDataProvider.getAllChallenges()).thenThrow(ConnectionException());
      when(() => mockDataProvider.getEnrolledChallengesNames()).thenAnswer((_) async => []);

      final result = await repository.getallChallenges();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ConnectionFailure>()),
        (challenges) => fail('Expected Left, got Right'),
      );
    });

    test('should throw UnknownFailure for other exceptions', () async {
      when(() => mockDataProvider.getAllChallenges()).thenThrow(Exception('Unknown error'));
      when(() => mockDataProvider.getEnrolledChallengesNames()).thenAnswer((_) async => []);

      expect(() => repository.getallChallenges(), throwsA(isA<UnknownFailure>()));
    });
  });
}