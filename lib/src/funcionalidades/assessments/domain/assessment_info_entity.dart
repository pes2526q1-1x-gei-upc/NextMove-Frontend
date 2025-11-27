import 'package:equatable/equatable.dart';

class AssessmentInfoEntity extends Equatable {
  final double averageScore;
  final int totalAssessments;

  const AssessmentInfoEntity({
    required this.averageScore,
    required this.totalAssessments,
  });

  @override
  List<Object?> get props => [averageScore, totalAssessments];
}