import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';
import 'package:nextmove_app/src/shared/domain/track_statistics.dart';

class MockRecordedTrack extends Mock implements RecordedTrack {}

class MockRecordedRoute extends Mock implements RecordedRoute {}

void main() {
  group('TrackStatistics', () {
    group('RecordedTrackWrapper', () {
      late RecordedTrack mockTrack;
      late RecordedTrackWrapper wrapper;

      setUp(() {
        mockTrack = MockRecordedTrack();
        wrapper = RecordedTrackWrapper(mockTrack);
      });

      test('totalDistanceMeters delegates to track', () {
        when(() => mockTrack.totalDistanceMeters).thenReturn(1000.0);
        expect(wrapper.totalDistanceMeters, 1000.0);
        verify(() => mockTrack.totalDistanceMeters).called(1);
      });

      test('averageSpeedKmH delegates to track', () {
        when(() => mockTrack.averageSpeedKmH).thenReturn(15.5);
        expect(wrapper.averageSpeedKmH, 15.5);
        verify(() => mockTrack.averageSpeedKmH).called(1);
      });

      test('maxSpeedKmH delegates to track', () {
        when(() => mockTrack.maxSpeedKmH).thenReturn(25.0);
        expect(wrapper.maxSpeedKmH, 25.0);
        verify(() => mockTrack.maxSpeedKmH).called(1);
      });

      test('co2SavedKG delegates to track', () {
        when(() => mockTrack.co2SavedKG).thenReturn(2.5);
        expect(wrapper.co2SavedKG, 2.5);
        verify(() => mockTrack.co2SavedKG).called(1);
      });

      test('kcalBurned delegates to track', () {
        when(() => mockTrack.kcalBurned).thenReturn(300.0);
        expect(wrapper.kcalBurned, 300.0);
        verify(() => mockTrack.kcalBurned).called(1);
      });

      test('elevationGainMeters delegates to track', () {
        when(() => mockTrack.elevationGainMeters).thenReturn(50.0);
        expect(wrapper.elevationGainMeters, 50.0);
        verify(() => mockTrack.elevationGainMeters).called(1);
      });

      test('elevationLossMeters delegates to track', () {
        when(() => mockTrack.elevationLossMeters).thenReturn(30.0);
        expect(wrapper.elevationLossMeters, 30.0);
        verify(() => mockTrack.elevationLossMeters).called(1);
      });
    });

    group('RecordedRouteWrapper', () {
      late RecordedRoute mockRoute;
      late RecordedRouteWrapper wrapper;

      setUp(() {
        mockRoute = MockRecordedRoute();
        wrapper = RecordedRouteWrapper(mockRoute);
      });

      test('totalDistanceMeters delegates to route.distance', () {
        when(() => mockRoute.distance).thenReturn(2000.0);
        expect(wrapper.totalDistanceMeters, 2000.0);
        verify(() => mockRoute.distance).called(1);
      });

      test('averageSpeedKmH delegates to route.averageSpeed with null handling', () {
        when(() => mockRoute.averageSpeed).thenReturn(20.0);
        expect(wrapper.averageSpeedKmH, 20.0);
        verify(() => mockRoute.averageSpeed).called(1);
      });

      test('averageSpeedKmH returns 0.0 when route.averageSpeed is null', () {
        when(() => mockRoute.averageSpeed).thenReturn(null);
        expect(wrapper.averageSpeedKmH, 0.0);
        verify(() => mockRoute.averageSpeed).called(1);
      });

      test('maxSpeedKmH delegates to route.maxSpeed with null handling', () {
        when(() => mockRoute.maxSpeed).thenReturn(30.0);
        expect(wrapper.maxSpeedKmH, 30.0);
        verify(() => mockRoute.maxSpeed).called(1);
      });

      test('maxSpeedKmH returns 0.0 when route.maxSpeed is null', () {
        when(() => mockRoute.maxSpeed).thenReturn(null);
        expect(wrapper.maxSpeedKmH, 0.0);
        verify(() => mockRoute.maxSpeed).called(1);
      });

      test('co2SavedKG delegates to route.co2 with null handling', () {
        when(() => mockRoute.co2).thenReturn(5.0);
        expect(wrapper.co2SavedKG, 5.0);
        verify(() => mockRoute.co2).called(1);
      });

      test('co2SavedKG returns 0.0 when route.co2 is null', () {
        when(() => mockRoute.co2).thenReturn(null);
        expect(wrapper.co2SavedKG, 0.0);
        verify(() => mockRoute.co2).called(1);
      });

      test('kcalBurned delegates to route.kcal with null handling', () {
        when(() => mockRoute.kcal).thenReturn(400.0);
        expect(wrapper.kcalBurned, 400.0);
        verify(() => mockRoute.kcal).called(1);
      });

      test('kcalBurned returns 0.0 when route.kcal is null', () {
        when(() => mockRoute.kcal).thenReturn(null);
        expect(wrapper.kcalBurned, 0.0);
        verify(() => mockRoute.kcal).called(1);
      });

      test('elevationGainMeters delegates to route.elevationGain with null handling', () {
        when(() => mockRoute.elevationGain).thenReturn(100.0);
        expect(wrapper.elevationGainMeters, 100.0);
        verify(() => mockRoute.elevationGain).called(1);
      });

      test('elevationGainMeters returns 0.0 when route.elevationGain is null', () {
        when(() => mockRoute.elevationGain).thenReturn(null);
        expect(wrapper.elevationGainMeters, 0.0);
        verify(() => mockRoute.elevationGain).called(1);
      });

      test('elevationLossMeters delegates to route.elevationLoss with null handling', () {
        when(() => mockRoute.elevationLoss).thenReturn(20.0);
        expect(wrapper.elevationLossMeters, 20.0);
        verify(() => mockRoute.elevationLoss).called(1);
      });

      test('elevationLossMeters returns 0.0 when route.elevationLoss is null', () {
        when(() => mockRoute.elevationLoss).thenReturn(null);
        expect(wrapper.elevationLossMeters, 0.0);
        verify(() => mockRoute.elevationLoss).called(1);
      });
    });
  });
}