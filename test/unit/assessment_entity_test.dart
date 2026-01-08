import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_entity.dart';

void main() {
  group('AssessmentEntity', () {
    test('should create entity with all required fields', () {
      final assessment = AssessmentEntity(
        nickname: 'testuser',
        stationId: 'station-1',
        score: 5,
        description: 'Great station!',
        createdAt: DateTime.parse('2022-01-01T00:00:00Z'),
      );

      expect(assessment.nickname, 'testuser');
      expect(assessment.stationId, 'station-1');
      expect(assessment.score, 5);
      expect(assessment.description, 'Great station!');
      expect(assessment.createdAt, DateTime.parse('2022-01-01T00:00:00Z'));
    });

    test('should create copy with updated fields', () {
      final original = AssessmentEntity(
        nickname: 'testuser',
        stationId: 'station-1',
        score: 5,
        description: 'Original description',
        createdAt: DateTime.parse('2022-01-01T00:00:00Z'),
      );

      final updated = original.copyWith(
        score: 4,
        description: 'Updated description',
      );

      expect(updated.score, 4);
      expect(updated.description, 'Updated description');
      expect(updated.nickname, original.nickname);
      expect(updated.stationId, original.stationId);
      expect(updated.createdAt, original.createdAt);
    });

    test('should maintain original values when copyWith fields are null', () {
      final original = AssessmentEntity(
        nickname: 'testuser',
        stationId: 'station-1',
        score: 5,
        description: 'Original description',
        createdAt: DateTime.parse('2022-01-01T00:00:00Z'),
      );

      final updated = original.copyWith();

      expect(updated.nickname, original.nickname);
      expect(updated.stationId, original.stationId);
      expect(updated.score, original.score);
      expect(updated.description, original.description);
      expect(updated.createdAt, original.createdAt);
    });

    test('should have correct props for equality', () {
      final assessment1 = AssessmentEntity(
        nickname: 'testuser',
        stationId: 'station-1',
        score: 5,
        description: 'Description',
        createdAt: DateTime.parse('2022-01-01T00:00:00Z'),
      );

      final assessment2 = AssessmentEntity(
        nickname: 'testuser',
        stationId: 'station-1',
        score: 5,
        description: 'Description',
        createdAt: DateTime.parse('2022-01-01T00:00:00Z'),
      );

      expect(assessment1, equals(assessment2));
    });
  });
}

