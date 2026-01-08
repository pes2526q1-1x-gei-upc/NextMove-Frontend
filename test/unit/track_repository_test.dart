import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/dataproviders/track_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/repositories/track_repository.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';

class MockTrackDataProvider extends Mock implements TrackDataProvider {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  late MockTrackDataProvider mockDataProvider;
  late MockAppLocalizations mockL10n;
  late TrackRepository repository;

  setUpAll(() {
    // Register fallback value for RecordedTrack
    registerFallbackValue(RecordedTrack());
  });

  setUp(() {
    mockDataProvider = MockTrackDataProvider();
    mockL10n = MockAppLocalizations();
    repository = TrackRepository(trackDataProvider: mockDataProvider);

    when(() => mockL10n.validationMinPoints(any())).thenReturn('Mínimo de puntos requerido');
    when(() => mockL10n.validationNoMovement).thenReturn('No hay movimiento');
    when(() => mockL10n.validationInconsistentTime).thenReturn('Tiempo inconsistente');
    when(() => mockL10n.validationImpossibleSpeed(any())).thenReturn('Velocidad imposible');
    when(() => mockL10n.validationSuspiciousGPS).thenReturn('GPS sospechoso');
    when(() => mockL10n.validationImpossibleMovements).thenReturn('Movimientos imposibles');
    when(() => mockL10n.validationMaxSpeedImpossible).thenReturn('Velocidad máxima imposible');
  });

  tearDown(() {
    reset(mockDataProvider);
    reset(mockL10n);
  });

  RecordedTrack createValidTrack() {
    final track = RecordedTrack();
    final baseTime = DateTime.now();
    track.addPoint(TrackPoint(
      location: LatLng(0.0, 0.0),
      altitude: 100.0,
      timestamp: baseTime,
    ));
    track.addPoint(TrackPoint(
      location: LatLng(0.001, 0.0),
      altitude: 100.0,
      timestamp: baseTime.add(Duration(seconds: 10)),
    ));
    track.addPoint(TrackPoint(
      location: LatLng(0.002, 0.0),
      altitude: 100.0,
      timestamp: baseTime.add(Duration(seconds: 20)),
    ));
    track.addPoint(TrackPoint(
      location: LatLng(0.003, 0.0),
      altitude: 100.0,
      timestamp: baseTime.add(Duration(seconds: 30)),
    ));
    return track;
  }

  group('TrackRepository', () {
    test('should return Right when track is valid and saved successfully', () async {
      final track = createValidTrack();
      when(() => mockDataProvider.saveRecordedTrack(track, bikePhoto: false))
          .thenAnswer((_) async {});

      final result = await repository.saveRecordedTrack(track, mockL10n);

      expect(result, isA<Right<Failure, void>>());
      verify(() => mockDataProvider.saveRecordedTrack(track, bikePhoto: false)).called(1);
    });

    test('should return Right when track is saved with bikePhoto true', () async {
      final track = createValidTrack();
      when(() => mockDataProvider.saveRecordedTrack(track, bikePhoto: true))
          .thenAnswer((_) async {});

      final result = await repository.saveRecordedTrack(track, mockL10n, bikePhoto: true);

      expect(result, isA<Right<Failure, void>>());
      verify(() => mockDataProvider.saveRecordedTrack(track, bikePhoto: true)).called(1);
    });

    test('should return ValidationFailure when track validation fails', () async {
      final track = RecordedTrack(); // Empty track (invalid)

      final result = await repository.saveRecordedTrack(track, mockL10n);

      expect(result, isA<Left<Failure, void>>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ValidationFailure>());
      verifyNever(() => mockDataProvider.saveRecordedTrack(any(), bikePhoto: any(named: 'bikePhoto')));
    });

    test('should return ServerFailure when ServerException is thrown', () async {
      final track = createValidTrack();
      when(() => mockDataProvider.saveRecordedTrack(track, bikePhoto: false))
          .thenThrow(ServerException('Server error'));

      final result = await repository.saveRecordedTrack(track, mockL10n);

      expect(result, isA<Left<Failure, void>>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, 'Server error');
    });

    test('should return ConnectionFailure when ConnectionException is thrown', () async {
      final track = createValidTrack();
      when(() => mockDataProvider.saveRecordedTrack(track, bikePhoto: false))
          .thenThrow(ConnectionException());

      final result = await repository.saveRecordedTrack(track, mockL10n);

      expect(result, isA<Left<Failure, void>>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ConnectionFailure>());
    });

    test('should return UnknownFailure when other exception is thrown', () async {
      final track = createValidTrack();
      when(() => mockDataProvider.saveRecordedTrack(track, bikePhoto: false))
          .thenThrow(Exception('Unknown error'));

      final result = await repository.saveRecordedTrack(track, mockL10n);

      expect(result, isA<Left<Failure, void>>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<UnknownFailure>());
    });

    test('should validate track before saving', () async {
      final track = RecordedTrack();
      // Add only 3 points (less than minimum 4)
      final baseTime = DateTime.now();
      track.addPoint(TrackPoint(
        location: LatLng(0.0, 0.0),
        altitude: 100.0,
        timestamp: baseTime,
      ));
      track.addPoint(TrackPoint(
        location: LatLng(0.001, 0.0),
        altitude: 100.0,
        timestamp: baseTime.add(Duration(seconds: 1)),
      ));
      track.addPoint(TrackPoint(
        location: LatLng(0.002, 0.0),
        altitude: 100.0,
        timestamp: baseTime.add(Duration(seconds: 2)),
      ));

      final result = await repository.saveRecordedTrack(track, mockL10n);

      expect(result, isA<Left<Failure, void>>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ValidationFailure>());
      verifyNever(() => mockDataProvider.saveRecordedTrack(any(), bikePhoto: any(named: 'bikePhoto')));
    });
  });
}

