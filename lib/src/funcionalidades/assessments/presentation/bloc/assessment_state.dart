import 'package:equatable/equatable.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_entity.dart';
enum AssessmentStatus { initial, loading, success, failure }class AssessmentState extends Equatable {
  final AssessmentStatus status;
  final String? errorMessage;
  final List<AssessmentEntity> assessments; // Lista de opiniones
  
  // NUEVOS CAMPOS
  final double averageScore;
  final int totalAssessments;

  const AssessmentState({
    this.status = AssessmentStatus.initial,
    this.errorMessage,
    this.assessments = const [],
    this.averageScore = 0.0,    
    this.totalAssessments = 0,  
  });

  AssessmentState copyWith({
    AssessmentStatus? status,
    String? errorMessage,
    List<AssessmentEntity>? assessments,
    double? averageScore,
    int? totalAssessments,
  }) {
    return AssessmentState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      assessments: assessments ?? this.assessments,
      averageScore: averageScore ?? this.averageScore,
      totalAssessments: totalAssessments ?? this.totalAssessments,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, assessments, averageScore, totalAssessments];
}