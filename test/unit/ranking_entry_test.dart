import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/competition/ranking/domain/ranking_entry.dart';

void main() {
  group('RankingEntry', () {
    test('constructor should create ranking entry with required fields', () {
      final entry = RankingEntry(
        email: 'test@example.com',
        nickname: 'testuser',
      );

      expect(entry.email, 'test@example.com');
      expect(entry.nickname, 'testuser');
      expect(entry.numberOfRoutes, isNull);
      expect(entry.distance, isNull);
      expect(entry.elevationGain, isNull);
      expect(entry.caloriesBurned, isNull);
      expect(entry.co2Saved, isNull);
      expect(entry.challengesParticipated, isNull);
      expect(entry.challengesCompleted, isNull);
      expect(entry.points, isNull);
    });

    test('constructor should create ranking entry with all fields', () {
      final entry = RankingEntry(
        email: 'test@example.com',
        nickname: 'testuser',
        numberOfRoutes: 10,
        distance: 100.5,
        elevationGain: 500.0,
        caloriesBurned: 2000.0,
        co2Saved: 50.0,
        challengesParticipated: 5,
        challengesCompleted: 3,
        points: 1000,
      );

      expect(entry.email, 'test@example.com');
      expect(entry.nickname, 'testuser');
      expect(entry.numberOfRoutes, 10);
      expect(entry.distance, 100.5);
      expect(entry.elevationGain, 500.0);
      expect(entry.caloriesBurned, 2000.0);
      expect(entry.co2Saved, 50.0);
      expect(entry.challengesParticipated, 5);
      expect(entry.challengesCompleted, 3);
      expect(entry.points, 1000);
    });

    group('fromJson', () {
      test('should parse JSON with all fields', () {
        final json = {
          'email': 'test@example.com',
          'nickname': 'testuser',
          'num_rutas': 10,
          'km_recorridos': 100.5,
          'elevacion_positiva': 500.0,
          'calorias_quemadas': 2000.0,
          'co2_ahorrado': 50.0,
          'num_retos_participados': 5,
          'num_retos_completados': 3,
          'puntos_totales': 1000,
        };

        final entry = RankingEntry.fromJson(json);

        expect(entry.email, 'test@example.com');
        expect(entry.nickname, 'testuser');
        expect(entry.numberOfRoutes, 10);
        expect(entry.distance, 100.5);
        expect(entry.elevationGain, 500.0);
        expect(entry.caloriesBurned, 2000.0);
        expect(entry.co2Saved, 50.0);
        expect(entry.challengesParticipated, 5);
        expect(entry.challengesCompleted, 3);
        expect(entry.points, 1000);
      });

      test('should parse JSON with null optional fields', () {
        final json = {
          'email': 'test@example.com',
          'nickname': 'testuser',
          'num_rutas': null,
          'km_recorridos': null,
          'elevacion_positiva': null,
          'calorias_quemadas': null,
          'co2_ahorrado': null,
          'num_retos_participados': null,
          'num_retos_completados': null,
          'puntos_totales': null,
        };

        final entry = RankingEntry.fromJson(json);

        expect(entry.email, 'test@example.com');
        expect(entry.nickname, 'testuser');
        expect(entry.numberOfRoutes, isNull);
        expect(entry.distance, isNull);
        expect(entry.elevationGain, isNull);
        expect(entry.caloriesBurned, isNull);
        expect(entry.co2Saved, isNull);
        expect(entry.challengesParticipated, isNull);
        expect(entry.challengesCompleted, isNull);
        expect(entry.points, isNull);
      });

      test('should parse JSON with missing optional fields', () {
        final json = {
          'email': 'test@example.com',
          'nickname': 'testuser',
        };

        final entry = RankingEntry.fromJson(json);

        expect(entry.email, 'test@example.com');
        expect(entry.nickname, 'testuser');
        expect(entry.numberOfRoutes, isNull);
        expect(entry.distance, isNull);
        expect(entry.elevationGain, isNull);
        expect(entry.caloriesBurned, isNull);
        expect(entry.co2Saved, isNull);
        expect(entry.challengesParticipated, isNull);
        expect(entry.challengesCompleted, isNull);
        expect(entry.points, isNull);
      });
    });
  });
}