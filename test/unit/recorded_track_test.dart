import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';

void main() {
  group('RecordedTrack', () {
    test('initialization', () {
      final track = RecordedTrack();
      expect(track.points, isEmpty);
      expect(track.totalDistanceMeters, 0.0);
      expect(track.averageSpeedKmH, 0.0);
      expect(track.maxSpeedKmH, 0.0);
      expect(track.totalTime, Duration.zero);
      expect(track.elevationGainMeters, 0.0);
      expect(track.elevationLossMeters, 0.0);
      expect(track.suspectedFraud, false);
      expect(track.co2SavedKG, 0.0);
      expect(track.kcalBurned, 0.0);
    });

    test('add first point', () {
      final track = RecordedTrack();
      final point = TrackPoint(
        location: LatLng(0.0, 0.0),
        altitude: 100.0,
        timestamp: DateTime.now(),
      );
      track.addPoint(point);
      expect(track.points.length, 1);
      expect(track.startPoint, point);
      expect(track.endPoint, point);
      expect(point.speed, 0.0);
      expect(track.totalDistanceMeters, 0.0);
      expect(track.averageSpeedKmH, 0.0);
      expect(track.maxSpeedKmH, 0.0);
      expect(track.totalTime, Duration.zero);
      expect(track.elevationGainMeters, 0.0);
      expect(track.elevationLossMeters, 0.0);
      expect(track.co2SavedKG, 0.0);
      expect(track.kcalBurned, 0.0);
    });

    test('add second point with distance and time', () {
      final track = RecordedTrack();
      final time1 = DateTime.now();
      final point1 = TrackPoint(
        location: LatLng(0.0, 0.0),
        altitude: 100.0,
        timestamp: time1,
      );
      track.addPoint(point1);

      final time2 = time1.add(Duration(seconds: 1));
      final point2 = TrackPoint(
        location: LatLng(0.001, 0.001), // approx 157m distance
        altitude: 105.0,
        timestamp: time2,
      );
      track.addPoint(point2);

      expect(track.points.length, 2);
      expect(track.endPoint, point2);
      expect(point2.speed, greaterThan(0.0));
      expect(track.totalDistanceMeters, greaterThan(0.0));
      expect(track.averageSpeedKmH, greaterThan(0.0));
      expect(track.maxSpeedKmH, greaterThan(0.0));
      expect(track.totalTime, Duration(seconds: 1));
      expect(track.elevationGainMeters, 5.0);
      expect(track.elevationLossMeters, 0.0);
      expect(track.co2SavedKG, greaterThan(0.0));
      expect(track.kcalBurned, greaterThan(0.0));
    });

    test('add point with elevation loss', () {
      final track = RecordedTrack();
      final point1 = TrackPoint(
        location: LatLng(0.0, 0.0),
        altitude: 100.0,
        timestamp: DateTime.now(),
      );
      track.addPoint(point1);

      final point2 = TrackPoint(
        location: LatLng(0.001, 0.001),
        altitude: 95.0,
        timestamp: DateTime.now().add(Duration(seconds: 1)),
      );
      track.addPoint(point2);

      expect(track.elevationGainMeters, 0.0);
      expect(track.elevationLossMeters, 5.0);
    });

    test('max speed update', () {
      final track = RecordedTrack();
      final point1 = TrackPoint(
        location: LatLng(0.0, 0.0),
        altitude: 100.0,
        timestamp: DateTime.now(),
      );
      track.addPoint(point1);

      final point2 = TrackPoint(
        location: LatLng(0.001, 0.001),
        altitude: 100.0,
        timestamp: DateTime.now().add(Duration(milliseconds: 100)),
      );
      track.addPoint(point2);

      final point3 = TrackPoint(
        location: LatLng(0.002, 0.002),
        altitude: 100.0,
        timestamp: DateTime.now().add(Duration(milliseconds: 200)),
      );
      track.addPoint(point3);

      expect(track.maxSpeedKmH, point2.speed);
    });

    test('toString output', () {
      final track = RecordedTrack();
      final output = track.toString();
      expect(output, contains('startTime'));
      expect(output, contains('endTime'));
      expect(output, contains('suspectedFraud'));
      expect(output, contains('totalDistanceMeters'));
      expect(output, contains('averageSpeedKmH'));
      expect(output, contains('maxSpeedKmH'));
      expect(output, contains('totalTime'));
      expect(output, contains('elevationGainMeters'));
      expect(output, contains('elevationLossMeters'));
      expect(output, contains('co2SavedKG'));
      expect(output, contains('kcalBurned'));
      expect(output, contains('number of points'));
    });

    test('add point with zero time difference', () {
      final track = RecordedTrack();
      final time = DateTime.now();
      final point1 = TrackPoint(
        location: LatLng(0.0, 0.0),
        altitude: 100.0,
        timestamp: time,
      );
      track.addPoint(point1);

      final point2 = TrackPoint(
        location: LatLng(0.001, 0.001),
        altitude: 100.0,
        timestamp: time, // same time
      );
      track.addPoint(point2);

      expect(track.points.length, 2);
      expect(point2.speed, 0.0); // speed should be 0 due to zero time
      expect(track.totalDistanceMeters, greaterThan(0.0));
      expect(track.averageSpeedKmH, 0.0); // average speed 0 due to totalTime 0
      expect(track.maxSpeedKmH, 0.0);
      expect(track.totalTime, Duration.zero);
    });

    test('add point with same location', () {
      final track = RecordedTrack();
      final time1 = DateTime.now();
      final point1 = TrackPoint(
        location: LatLng(0.0, 0.0),
        altitude: 100.0,
        timestamp: time1,
      );
      track.addPoint(point1);

      final time2 = time1.add(Duration(seconds: 1));
      final point2 = TrackPoint(
        location: LatLng(0.0, 0.0), // same location
        altitude: 100.0,
        timestamp: time2,
      );
      track.addPoint(point2);

      expect(track.points.length, 2);
      expect(point2.speed, 0.0);
      expect(track.totalDistanceMeters, 0.0);
      expect(track.averageSpeedKmH, 0.0);
      expect(track.maxSpeedKmH, 0.0);
      expect(track.totalTime, Duration(seconds: 1));
      expect(track.elevationGainMeters, 0.0);
      expect(track.elevationLossMeters, 0.0);
    });

    test('add point with negative time difference', () {
      final track = RecordedTrack();
      final time1 = DateTime.now();
      final point1 = TrackPoint(
        location: LatLng(0.0, 0.0),
        altitude: 100.0,
        timestamp: time1,
      );
      track.addPoint(point1);

      final time2 = time1.subtract(Duration(seconds: 1)); // earlier time
      final point2 = TrackPoint(
        location: LatLng(0.001, 0.001),
        altitude: 100.0,
        timestamp: time2,
      );
      track.addPoint(point2);

      expect(track.points.length, 2);
      expect(point2.speed, lessThan(0.0)); // negative speed
      expect(track.totalDistanceMeters, greaterThan(0.0));
      expect(track.averageSpeedKmH, lessThan(0.0)); // negative average
      expect(track.maxSpeedKmH, 0.0); // max speed not updated for negative
      expect(track.totalTime, Duration(seconds: -1));
    });

    test('extreme large distance', () {
      final track = RecordedTrack();
      final time1 = DateTime.now();
      final point1 = TrackPoint(
        location: LatLng(0.0, 0.0), // equator
        altitude: 0.0,
        timestamp: time1,
      );
      track.addPoint(point1);

      final time2 = time1.add(Duration(hours: 1));
      final point2 = TrackPoint(
        location: LatLng(0.0, 10.0), // 10 degrees east, approx 1113 km
        altitude: 0.0,
        timestamp: time2,
      );
      track.addPoint(point2);

      expect(track.totalDistanceMeters, closeTo(1113000, 10000)); // approx 1113 km
      expect(track.averageSpeedKmH, closeTo(1113, 100)); // approx 1113 km/h
      expect(track.maxSpeedKmH, closeTo(1113, 100));
      expect(track.co2SavedKG, closeTo(213, 20)); // 1113km * 0.192
      expect(track.kcalBurned, closeTo(44520, 1000)); // 1113km * 40
    });

    test('negative altitudes', () {
      final track = RecordedTrack();
      final time1 = DateTime.now();
      final point1 = TrackPoint(
        location: LatLng(0.0, 0.0),
        altitude: -100.0,
        timestamp: time1,
      );
      track.addPoint(point1);

      final time2 = time1.add(Duration(seconds: 1));
      final point2 = TrackPoint(
        location: LatLng(0.001, 0.001),
        altitude: -200.0, // lower
        timestamp: time2,
      );
      track.addPoint(point2);

      expect(track.elevationGainMeters, 0.0);
      expect(track.elevationLossMeters, 100.0);
    });

    test('multiple elevation changes', () {
      final track = RecordedTrack();
      final baseTime = DateTime.now();
      final points = [
        TrackPoint(location: LatLng(0.0, 0.0), altitude: 100.0, timestamp: baseTime),
        TrackPoint(location: LatLng(0.001, 0.0), altitude: 110.0, timestamp: baseTime.add(Duration(seconds: 1))), // +10
        TrackPoint(location: LatLng(0.002, 0.0), altitude: 105.0, timestamp: baseTime.add(Duration(seconds: 2))), // -5
        TrackPoint(location: LatLng(0.003, 0.0), altitude: 115.0, timestamp: baseTime.add(Duration(seconds: 3))), // +10
        TrackPoint(location: LatLng(0.004, 0.0), altitude: 100.0, timestamp: baseTime.add(Duration(seconds: 4))), // -15
      ];

      for (final point in points) {
        track.addPoint(point);
      }

      expect(track.elevationGainMeters, (10.0 + 10.0));
      expect(track.elevationLossMeters, (5.0 + 15.0));
    });

    test('many points performance', () {
      int pointsCount = 10000;
      final track = RecordedTrack();
      final baseTime = DateTime.now();
      final random = Random(42); // Seed for reproducible randomness
      for (int i = 0; i < pointsCount; i++) {
      final lat = random.nextDouble() * 0.1 - 0.05; // Random lat between -0.05 and 0.05
      final lng = random.nextDouble() * 0.1 - 0.05; // Random lng between -0.05 and 0.05
      final alt = 90.0 + random.nextDouble() * 20.0; // Random altitude between 90.0 and 110.0
      final timeOffset = Duration(seconds: i + 1);
      final point = TrackPoint(
        location: LatLng(lat, lng),
        altitude: alt,
        timestamp: baseTime.add(timeOffset),
      );
      track.addPoint(point);
      }

      expect(track.points.length, pointsCount);
      expect(track.totalDistanceMeters, greaterThan(0.0));
      expect(track.averageSpeedKmH, greaterThan(0.0));
      expect(track.maxSpeedKmH, greaterThan(0.0));
      expect(track.totalTime, Duration(seconds: pointsCount - 1));
      expect(track.elevationGainMeters, greaterThan(0.0));
      expect(track.elevationLossMeters, greaterThan(0.0));
    });

    test('varying speeds for max speed', () {
      final track = RecordedTrack();
      final baseTime = DateTime.now();
      // Add points with increasing speed
      final points = [
        TrackPoint(location: LatLng(0.0, 0.0), altitude: 100.0, timestamp: baseTime),
        TrackPoint(location: LatLng(0.001, 0.0), altitude: 100.0, timestamp: baseTime.add(Duration(milliseconds: 1000))), // slow
        TrackPoint(location: LatLng(0.002, 0.0), altitude: 100.0, timestamp: baseTime.add(Duration(milliseconds: 1100))), // fast
        TrackPoint(location: LatLng(0.003, 0.0), altitude: 100.0, timestamp: baseTime.add(Duration(milliseconds: 1110))), // very fast
      ];

      for (final point in points) {
        track.addPoint(point);
      }

      expect(track.maxSpeedKmH, points.last.speed);
    });

    test('co2 and kcal calculations', () {
      final track = RecordedTrack();
      final baseTime = DateTime.now();
      final point1 = TrackPoint(location: LatLng(0.0, 0.0), altitude: 100.0, timestamp: baseTime);
      track.addPoint(point1);
      final point2 = TrackPoint(location: LatLng(0.00899, 0.0), altitude: 100.0, timestamp: baseTime.add(Duration(seconds: 1)));
      track.addPoint(point2);

      expect(track.totalDistanceMeters, closeTo(1000, 10));
      expect(track.co2SavedKG, closeTo(0.192, 0.01));
      expect(track.kcalBurned, closeTo(40, 1));
    });
  });
}