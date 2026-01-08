import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:io';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/data/dataproviders/assessments_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/data/repositories/assessment_repository.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_entity.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_info_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/data/repositories/user_repository.dart';

class MockAssessmentRemoteDataProvider extends Mock implements AssessmentRemoteDataProvider {}
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late AssessmentRepository repository;
  late MockAssessmentRemoteDataProvider mockDataProvider;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockDataProvider = MockAssessmentRemoteDataProvider();
    mockUserRepository = MockUserRepository();
    repository = AssessmentRepository(
      remoteDataProvider: mockDataProvider,
      userRepository: mockUserRepository,
    );
  });

  group('AssessmentRepository', () {
    group('createAssessment', () {
      test('should return Right(null) when data provider succeeds', () async {
        when(() => mockDataProvider.createAssessment(
          any(),
          any(),
          any(),
        )).thenAnswer((_) async => Future.value());

        final result = await repository.createAssessment(
          stationId: 'station-1',
          score: 5,
          comment: 'Great station',
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (_) {},
        );
        verify(() => mockDataProvider.createAssessment('station-1', 5, 'Great station')).called(1);
      });

      test('should return ConnectionFailure when SocketException is thrown', () async {
        when(() => mockDataProvider.createAssessment(
          any(),
          any(),
          any(),
        )).thenThrow(SocketException('No internet'));

        final result = await repository.createAssessment(
          stationId: 'station-1',
          score: 5,
          comment: 'Great station',
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ConnectionFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.createAssessment(
          any(),
          any(),
          any(),
        )).thenThrow(ServerException('Server error'));

        final result = await repository.createAssessment(
          stationId: 'station-1',
          score: 5,
          comment: 'Great station',
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect((failure as ServerFailure).message, 'Server error');
          },
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('getAssessmentsByStation', () {
      test('should return list of assessments when data provider succeeds', () async {
        final mockAssessments = [
          AssessmentEntity(
            nickname: 'user1',
            stationId: 'station-1',
            score: 5,
            description: 'Great',
            createdAt: DateTime.now(),
          ),
          AssessmentEntity(
            nickname: 'user2',
            stationId: 'station-1',
            score: 4,
            description: 'Good',
            createdAt: DateTime.now(),
          ),
        ];

        when(() => mockDataProvider.getAssessmentsByStation(any()))
            .thenAnswer((_) async => mockAssessments);

        final result = await repository.getAssessmentsByStation('station-1');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (assessments) {
            expect(assessments.length, 2);
            expect(assessments[0].nickname, 'user1');
            expect(assessments[1].nickname, 'user2');
          },
        );
        verify(() => mockDataProvider.getAssessmentsByStation('station-1')).called(1);
      });

      test('should return ConnectionFailure when SocketException is thrown', () async {
        when(() => mockDataProvider.getAssessmentsByStation(any()))
            .thenThrow(SocketException('No internet'));

        final result = await repository.getAssessmentsByStation('station-1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ConnectionFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.getAssessmentsByStation(any()))
            .thenThrow(ServerException('Server error'));

        final result = await repository.getAssessmentsByStation('station-1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('getStationAssessmentInfo', () {
      test('should return AssessmentInfoEntity when data provider succeeds', () async {
        const mockInfo = AssessmentInfoEntity(
          averageScore: 4.5,
          totalAssessments: 10,
        );

        when(() => mockDataProvider.getStationAssessmentInfo(any()))
            .thenAnswer((_) async => mockInfo);

        final result = await repository.getStationAssessmentInfo('station-1');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (info) {
            expect(info.averageScore, 4.5);
            expect(info.totalAssessments, 10);
          },
        );
        verify(() => mockDataProvider.getStationAssessmentInfo('station-1')).called(1);
      });

      test('should return ConnectionFailure when SocketException is thrown', () async {
        when(() => mockDataProvider.getStationAssessmentInfo(any()))
            .thenThrow(SocketException('No internet'));

        final result = await repository.getStationAssessmentInfo('station-1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ConnectionFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('updateAssessment', () {
      test('should return Right(null) when data provider succeeds', () async {
        when(() => mockDataProvider.updateAssessment(
          any(),
          any(),
          any(),
        )).thenAnswer((_) async => Future.value());

        final result = await repository.updateAssessment(
          stationId: 'station-1',
          score: 4,
          comment: 'Updated comment',
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (_) {},
        );
        verify(() => mockDataProvider.updateAssessment('station-1', 4, 'Updated comment')).called(1);
      });

      test('should return ConnectionFailure when SocketException is thrown', () async {
        when(() => mockDataProvider.updateAssessment(
          any(),
          any(),
          any(),
        )).thenThrow(SocketException('No internet'));

        final result = await repository.updateAssessment(
          stationId: 'station-1',
          score: 4,
          comment: 'Updated comment',
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ConnectionFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('deleteAssessment', () {
      test('should return Right(null) when data provider succeeds', () async {
        when(() => mockDataProvider.deleteAssessment(any()))
            .thenAnswer((_) async => Future.value());

        final result = await repository.deleteAssessment('station-1');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (_) {},
        );
        verify(() => mockDataProvider.deleteAssessment('station-1')).called(1);
      });

      test('should return ServerFailure when exception is thrown', () async {
        when(() => mockDataProvider.deleteAssessment(any()))
            .thenThrow(Exception('Error'));

        final result = await repository.deleteAssessment('station-1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('checkAssessed', () {
      test('should return Right(true) when user has assessed', () async {
        when(() => mockDataProvider.checkAssessed(any()))
            .thenAnswer((_) async => true);

        final result = await repository.checkAssessed('station-1');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (hasAssessed) => expect(hasAssessed, true),
        );
        verify(() => mockDataProvider.checkAssessed('station-1')).called(1);
      });

      test('should return Right(false) when user has not assessed', () async {
        when(() => mockDataProvider.checkAssessed(any()))
            .thenAnswer((_) async => false);

        final result = await repository.checkAssessed('station-1');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (hasAssessed) => expect(hasAssessed, false),
        );
      });

      test('should return ConnectionFailure when SocketException is thrown', () async {
        when(() => mockDataProvider.checkAssessed(any()))
            .thenThrow(SocketException('No internet'));

        final result = await repository.checkAssessed('station-1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ConnectionFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });
  });
}
