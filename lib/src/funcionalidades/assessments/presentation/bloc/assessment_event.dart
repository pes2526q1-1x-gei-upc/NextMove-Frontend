import 'package:equatable/equatable.dart';

abstract class AssessmentEvent extends Equatable {
  const AssessmentEvent();

  @override
  List<Object?> get props => [];
}

class CreateAssessmentEvent extends AssessmentEvent {
  final String stationId;
  final int score;
  final String comment;

  const CreateAssessmentEvent({
    required this.stationId,
    required this.score,
    required this.comment,
  });

  @override
  List<Object?> get props => [stationId, score, comment];
}
class GetAssessmentsByStationEvent extends AssessmentEvent {
  final String stationId;

  const GetAssessmentsByStationEvent({required this.stationId});

  @override
  List<Object?> get props => [stationId];
}

class GetStationAssessmentInfoEvent extends AssessmentEvent {
  final String stationId;

  const GetStationAssessmentInfoEvent({required this.stationId});

  @override
  List<Object?> get props => [stationId];
}