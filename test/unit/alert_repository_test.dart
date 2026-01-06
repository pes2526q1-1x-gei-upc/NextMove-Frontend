import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/alerts/datos/dataproviders/alert_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/alerts/datos/repositories/alert_repository.dart';
import 'package:nextmove_app/src/funcionalidades/alerts/dominio/alert_entity.dart';

class MockAlertRemoteDataProvider extends Mock implements AlertRemoteDataProvider {}

void main() {
  late AlertRepository repository;
  late MockAlertRemoteDataProvider mockDataProvider;

  setUp(() {
    mockDataProvider = MockAlertRemoteDataProvider();
    repository = AlertRepository(alertRemoteDataProvider: mockDataProvider);
  });

  group('AlertRepository', () {
    group('getStationAlerts', () {
      test('should return list of alerts when data provider succeeds', () async {
        final mockAlerts = [
          StationAlert(
            id: 'alert-1',
            userEmail: 'user@example.com',
            stationId: 'station-1',
            horas: ['08:00', '18:00'],
            diasSemana: [1, 3, 5],
            activa: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          StationAlert(
            id: 'alert-2',
            userEmail: 'user@example.com',
            stationId: 'station-2',
            horas: ['09:00'],
            diasSemana: [2, 4],
            activa: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(() => mockDataProvider.getStationAlerts())
            .thenAnswer((_) async => mockAlerts);

        final result = await repository.getStationAlerts();

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (alerts) {
            expect(alerts.length, 2);
            expect(alerts[0].id, 'alert-1');
            expect(alerts[1].id, 'alert-2');
          },
        );
        verify(() => mockDataProvider.getStationAlerts()).called(1);
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.getStationAlerts())
            .thenThrow(ServerException('Server error'));

        final result = await repository.getStationAlerts();

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect((failure as ServerFailure).message, 'Server error');
          },
          (_) => fail('Expected Left, got Right'),
        );
      });

      test('should return ConnectionFailure when ConnectionException is thrown', () async {
        when(() => mockDataProvider.getStationAlerts())
            .thenThrow(ConnectionException());

        final result = await repository.getStationAlerts();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ConnectionFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });

      test('should return UnknownFailure when other exception is thrown', () async {
        when(() => mockDataProvider.getStationAlerts())
            .thenThrow(Exception('Unknown error'));

        final result = await repository.getStationAlerts();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('getStationAlert', () {
      test('should return alert when data provider succeeds', () async {
        final mockAlert = StationAlert(
          id: 'alert-1',
          userEmail: 'user@example.com',
          stationId: 'station-1',
          horas: ['08:00'],
          diasSemana: [1],
          activa: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockDataProvider.getStationAlert('alert-1'))
            .thenAnswer((_) async => mockAlert);

        final result = await repository.getStationAlert('alert-1');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (alert) {
            expect(alert, isNotNull);
            expect(alert!.id, 'alert-1');
            expect(alert.stationId, 'station-1');
          },
        );
        verify(() => mockDataProvider.getStationAlert('alert-1')).called(1);
      });

      test('should return null alert when data provider returns null', () async {
        when(() => mockDataProvider.getStationAlert('alert-1'))
            .thenAnswer((_) async => null);

        final result = await repository.getStationAlert('alert-1');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (alert) => expect(alert, isNull),
        );
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.getStationAlert('alert-1'))
            .thenThrow(ServerException('Server error'));

        final result = await repository.getStationAlert('alert-1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('createStationAlert', () {
      test('should return created alert when data provider succeeds', () async {
        final mockAlert = StationAlert(
          id: 'alert-1',
          userEmail: 'user@example.com',
          stationId: 'station-1',
          horas: ['08:00', '18:00'],
          diasSemana: [1, 3, 5],
          activa: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockDataProvider.createStationAlert(
          stationId: 'station-1',
          horas: ['08:00', '18:00'],
          diasSemana: [1, 3, 5],
        )).thenAnswer((_) async => mockAlert);

        final result = await repository.createStationAlert(
          stationId: 'station-1',
          horas: ['08:00', '18:00'],
          diasSemana: [1, 3, 5],
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (alert) {
            expect(alert.id, 'alert-1');
            expect(alert.stationId, 'station-1');
            expect(alert.horas.length, 2);
          },
        );
        verify(() => mockDataProvider.createStationAlert(
          stationId: 'station-1',
          horas: ['08:00', '18:00'],
          diasSemana: [1, 3, 5],
        )).called(1);
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.createStationAlert(
          stationId: any(named: 'stationId'),
          horas: any(named: 'horas'),
          diasSemana: any(named: 'diasSemana'),
        )).thenThrow(ServerException('Server error'));

        final result = await repository.createStationAlert(
          stationId: 'station-1',
          horas: ['08:00'],
          diasSemana: [1],
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('updateStationAlert', () {
      test('should return updated alert when data provider succeeds', () async {
        final mockAlert = StationAlert(
          id: 'alert-1',
          userEmail: 'user@example.com',
          stationId: 'station-1',
          horas: ['09:00'],
          diasSemana: [2, 4],
          activa: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockDataProvider.updateStationAlert(
          id: 'alert-1',
          horas: ['09:00'],
          diasSemana: [2, 4],
          activa: null,
        )).thenAnswer((_) async => mockAlert);

        final result = await repository.updateStationAlert(
          id: 'alert-1',
          horas: ['09:00'],
          diasSemana: [2, 4],
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (alert) {
            expect(alert.id, 'alert-1');
            expect(alert.horas, ['09:00']);
          },
        );
        verify(() => mockDataProvider.updateStationAlert(
          id: 'alert-1',
          horas: ['09:00'],
          diasSemana: [2, 4],
          activa: null,
        )).called(1);
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.updateStationAlert(
          id: any(named: 'id'),
          horas: any(named: 'horas'),
          diasSemana: any(named: 'diasSemana'),
          activa: any(named: 'activa'),
        )).thenThrow(ServerException('Server error'));

        final result = await repository.updateStationAlert(
          id: 'alert-1',
          horas: ['09:00'],
          diasSemana: [2],
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('deleteStationAlert', () {
      test('should return true when data provider succeeds', () async {
        when(() => mockDataProvider.deleteStationAlert('alert-1'))
            .thenAnswer((_) async => true);

        final result = await repository.deleteStationAlert('alert-1');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (deleted) => expect(deleted, true),
        );
        verify(() => mockDataProvider.deleteStationAlert('alert-1')).called(1);
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.deleteStationAlert('alert-1'))
            .thenThrow(ServerException('Server error'));

        final result = await repository.deleteStationAlert('alert-1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });

    group('toggleStationAlert', () {
      test('should return toggled alert when data provider succeeds', () async {
        final mockAlert = StationAlert(
          id: 'alert-1',
          userEmail: 'user@example.com',
          stationId: 'station-1',
          horas: ['08:00'],
          diasSemana: [1],
          activa: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockDataProvider.toggleStationAlert('alert-1', false))
            .thenAnswer((_) async => mockAlert);

        final result = await repository.toggleStationAlert('alert-1', false);

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left'),
          (alert) {
            expect(alert.id, 'alert-1');
            expect(alert.activa, false);
          },
        );
        verify(() => mockDataProvider.toggleStationAlert('alert-1', false)).called(1);
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        when(() => mockDataProvider.toggleStationAlert('alert-1', true))
            .thenThrow(ServerException('Server error'));

        final result = await repository.toggleStationAlert('alert-1', true);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left, got Right'),
        );
      });
    });
  });
}
