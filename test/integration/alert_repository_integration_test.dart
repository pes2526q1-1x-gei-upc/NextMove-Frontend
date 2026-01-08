import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/alerts/datos/dataproviders/alert_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/alerts/datos/repositories/alert_repository.dart';
import 'package:nextmove_app/src/funcionalidades/alerts/dominio/alert_entity.dart';

class MockAlertRemoteDataProvider extends Mock implements AlertRemoteDataProvider {}

void main() {
  group('AlertRepository Integration Tests', () {
    late AlertRepository repository;
    late MockAlertRemoteDataProvider mockDataProvider;

    setUp(() {
      mockDataProvider = MockAlertRemoteDataProvider();
      repository = AlertRepository(alertRemoteDataProvider: mockDataProvider);
    });

    test('should integrate repository and data provider for getStationAlerts flow', () async {
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
      ];

      when(() => mockDataProvider.getStationAlerts())
          .thenAnswer((_) async => mockAlerts);

      final result = await repository.getStationAlerts();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right, got Left: $failure'),
        (alerts) {
          expect(alerts.length, 1);
          expect(alerts[0].id, 'alert-1');
          expect(alerts[0].stationId, 'station-1');
        },
      );

      verify(() => mockDataProvider.getStationAlerts()).called(1);
    });

    test('should integrate error handling between repository and data provider', () async {
      when(() => mockDataProvider.getStationAlerts())
          .thenThrow(ServerException('Error del servidor'));

      final result = await repository.getStationAlerts();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message, 'Error del servidor');
        },
        (_) => fail('Expected Left (Failure), got Right'),
      );

      verify(() => mockDataProvider.getStationAlerts()).called(1);
    });

    test('should integrate create and get flow together', () async {
      final createdAlert = StationAlert(
        id: 'alert-new',
        userEmail: 'user@example.com',
        stationId: 'station-1',
        horas: ['09:00'],
        diasSemana: [2],
        activa: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockDataProvider.createStationAlert(
        stationId: 'station-1',
        horas: ['09:00'],
        diasSemana: [2],
      )).thenAnswer((_) async => createdAlert);

      when(() => mockDataProvider.getStationAlert('alert-new'))
          .thenAnswer((_) async => createdAlert);

      final createResult = await repository.createStationAlert(
        stationId: 'station-1',
        horas: ['09:00'],
        diasSemana: [2],
      );

      final getResult = await repository.getStationAlert('alert-new');

      expect(createResult.isRight(), true);
      createResult.fold(
        (failure) => fail('Create should succeed'),
        (alert) => expect(alert.id, 'alert-new'),
      );

      expect(getResult.isRight(), true);
      getResult.fold(
        (failure) => fail('Get should succeed'),
        (alert) {
          expect(alert, isNotNull);
          expect(alert!.id, 'alert-new');
        },
      );

      verify(() => mockDataProvider.createStationAlert(
        stationId: 'station-1',
        horas: ['09:00'],
        diasSemana: [2],
      )).called(1);
      verify(() => mockDataProvider.getStationAlert('alert-new')).called(1);
    });
  });
}

