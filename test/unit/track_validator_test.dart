import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/track_validator.dart';

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  late MockAppLocalizations mockL10n;
  late TrackValidator validator;

  setUp(() {
    mockL10n = MockAppLocalizations();
    validator = TrackValidator(mockL10n);

    // Setup default return values for localization methods
    when(() => mockL10n.validationMinPoints(any())).thenReturn('Mínimo de puntos requerido');
    when(() => mockL10n.validationNoMovement).thenReturn('No hay movimiento');
    when(() => mockL10n.validationInconsistentTime).thenReturn('Tiempo inconsistente');
    when(() => mockL10n.validationImpossibleSpeed(any())).thenReturn('Velocidad imposible');
    when(() => mockL10n.validationSuspiciousGPS).thenReturn('GPS sospechoso');
    when(() => mockL10n.validationImpossibleMovements).thenReturn('Movimientos imposibles');
    when(() => mockL10n.validationMaxSpeedImpossible).thenReturn('Velocidad máxima imposible');
  });

  tearDown(() {
    reset(mockL10n);
  });

  group('TrackValidator', () {
    test('should return invalid when track has less than minimum points', () {
      final track = RecordedTrack();
      // Add only 3 points (minimum is 4)
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

      final result = validator.validate(track);

      expect(result.isValid, false);
      expect(result.reason, isNotNull);
      verify(() => mockL10n.validationMinPoints(4)).called(1);
    });

    test('should return invalid when total distance is less than minimum', () {
      final track = RecordedTrack();
      final baseTime = DateTime.now();
      // Add 4 points but with very small distance
      track.addPoint(TrackPoint(
        location: LatLng(0.0, 0.0),
        altitude: 100.0,
        timestamp: baseTime,
      ));
      track.addPoint(TrackPoint(
        location: LatLng(0.00001, 0.0), // Very small distance
        altitude: 100.0,
        timestamp: baseTime.add(Duration(seconds: 1)),
      ));
      track.addPoint(TrackPoint(
        location: LatLng(0.00002, 0.0),
        altitude: 100.0,
        timestamp: baseTime.add(Duration(seconds: 2)),
      ));
      track.addPoint(TrackPoint(
        location: LatLng(0.00003, 0.0),
        altitude: 100.0,
        timestamp: baseTime.add(Duration(seconds: 3)),
      ));

      final result = validator.validate(track);

      expect(result.isValid, false);
      expect(result.reason, isNotNull);
      verify(() => mockL10n.validationNoMovement).called(1);
    });

    test('should return invalid when timestamps are inconsistent', () {
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
        timestamp: baseTime.add(Duration(seconds: 1)),
      ));
      track.addPoint(TrackPoint(
        location: LatLng(0.002, 0.0),
        altitude: 100.0,
        timestamp: baseTime.subtract(Duration(seconds: 1)), // Earlier timestamp
      ));
      track.addPoint(TrackPoint(
        location: LatLng(0.003, 0.0),
        altitude: 100.0,
        timestamp: baseTime.add(Duration(seconds: 2)),
      ));

      final result = validator.validate(track);

      expect(result.isValid, false);
      expect(result.reason, isNotNull);
      verify(() => mockL10n.validationInconsistentTime).called(1);
    });

    test('should return invalid when speed exceeds maximum realistic speed', () {
      final track = RecordedTrack();
      final baseTime = DateTime.now();
      track.addPoint(TrackPoint(
        location: LatLng(0.0, 0.0),
        altitude: 100.0,
        timestamp: baseTime,
      ));
      track.addPoint(TrackPoint(
        location: LatLng(0.1, 0.0),
        altitude: 100.0,
        timestamp: baseTime.add(Duration(milliseconds: 100)),
      ));
      track.addPoint(TrackPoint(
        location: LatLng(0.11, 0.0),
        altitude: 100.0,
        timestamp: baseTime.add(Duration(milliseconds: 200)),
      ));
      track.addPoint(TrackPoint(
        location: LatLng(0.12, 0.0),
        altitude: 100.0,
        timestamp: baseTime.add(Duration(milliseconds: 300)),
      ));

      final result = validator.validate(track);

      expect(result.isValid, false);
      expect(result.reason, isNotNull);
      verify(() => mockL10n.validationImpossibleSpeed(any())).called(1);
    });

    test('should return invalid when too many identical points', () {
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
      for (int i = 2; i < 10; i++) {
        track.addPoint(TrackPoint(
          location: LatLng(0.001, 0.0),
          altitude: 100.0,
          timestamp: baseTime.add(Duration(seconds: 10 + i * 10)),
        ));
      }

      final result = validator.validate(track);

      expect(result.isValid, false);
      expect(result.reason, isNotNull);
      verify(() => mockL10n.validationSuspiciousGPS).called(1);
    });

    test('should return invalid when too many suspicious jumps', () {
      final track = RecordedTrack();
      final baseTime = DateTime.now();
      track.addPoint(TrackPoint(
        location: LatLng(0.0, 0.0),
        altitude: 100.0,
        timestamp: baseTime,
      ));
      for (int i = 1; i <= 2; i++) {
        track.addPoint(TrackPoint(
          location: LatLng(0.005 * i, 0.0),
          altitude: 100.0,
          timestamp: baseTime.add(Duration(seconds: 5 * i)),
        ));
      }
      track.addPoint(TrackPoint(
        location: LatLng(0.001, 0.0),
        altitude: 100.0,
        timestamp: baseTime.add(Duration(seconds: 20)),
      ));
      track.addPoint(TrackPoint(
        location: LatLng(0.002, 0.0),
        altitude: 100.0,
        timestamp: baseTime.add(Duration(seconds: 30)),
      ));

      final result = validator.validate(track);

      expect(result.isValid, false);
      expect(result.reason, isNotNull);
      verify(() => mockL10n.validationImpossibleSpeed(any())).called(1);
    });

    test('should return invalid when individual speed exceeds limit', () {
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
        location: LatLng(0.01, 0.0),
        altitude: 100.0,
        timestamp: baseTime.add(Duration(seconds: 21)),
      ));

      final result = validator.validate(track);

      expect(result.isValid, false);
      expect(result.reason, isNotNull);
      verify(() => mockL10n.validationImpossibleSpeed(any())).called(1);
    });

    test('should return valid for a normal track', () {
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

      final result = validator.validate(track);

      expect(result.isValid, true);
      expect(result.reason, isNull);
    });

    test('should handle empty track', () {
      final track = RecordedTrack();

      final result = validator.validate(track);

      expect(result.isValid, false);
      expect(result.reason, isNotNull);
      verify(() => mockL10n.validationMinPoints(4)).called(1);
    });
  });
}

