import 'package:equatable/equatable.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_entity.dart';

enum AssessmentStatus { initial, loading, success, failure }

class AssessmentState extends Equatable {
  final AssessmentStatus status;
  final String? errorMessage;
  final List<AssessmentEntity> assessments;

  final double averageScore;
  final int totalAssessments;
  final bool userHasAssessed;

  const AssessmentState({
    this.status = AssessmentStatus.initial,
    this.errorMessage,
    this.assessments = const [],
    this.averageScore = 0.0,
    this.totalAssessments = 0,
    this.userHasAssessed = false,
  });

  AssessmentState copyWith({
    AssessmentStatus? status,
    String? errorMessage,
    List<AssessmentEntity>? assessments,
    double? averageScore,
    int? totalAssessments,
    bool? userHasAssessed,
  }) {
    return AssessmentState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      assessments: assessments ?? this.assessments,
      averageScore: averageScore ?? this.averageScore,
      totalAssessments: totalAssessments ?? this.totalAssessments,
      userHasAssessed: userHasAssessed ?? this.userHasAssessed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    assessments,
    averageScore,
    totalAssessments,
    userHasAssessed,
  ];
}
