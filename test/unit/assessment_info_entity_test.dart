import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_info_entity.dart';

void main() {
  group('AssessmentInfoEntity', () {
    const assessmentInfo = AssessmentInfoEntity(
      averageScore: 4.2,
      totalAssessments: 15,
    );

    test('should create AssessmentInfoEntity with correct properties', () {
      expect(assessmentInfo.averageScore, 4.2);
      expect(assessmentInfo.totalAssessments, 15);
    });

    test('props should return correct list', () {
      expect(assessmentInfo.props, [4.2, 15]);
    });

    test('should be equal when all properties are equal', () {
      const other = AssessmentInfoEntity(
        averageScore: 4.2,
        totalAssessments: 15,
      );

      expect(assessmentInfo, other);
    });

    test('should not be equal when properties differ', () {
      const other = AssessmentInfoEntity(
        averageScore: 3.8,
        totalAssessments: 15,
      );

      expect(assessmentInfo, isNot(other));
    });
  });
}