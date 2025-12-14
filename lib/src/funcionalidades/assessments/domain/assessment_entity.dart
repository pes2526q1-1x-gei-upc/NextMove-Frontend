import 'package:equatable/equatable.dart';

class AssessmentEntity extends Equatable {
  final String nickname;
  final String stationId;
  final int score;
  final String description;
  final DateTime createdAt;

  const AssessmentEntity({
    required this.nickname,
    required this.stationId,
    required this.score,
    required this.description,
    required this.createdAt,
  });

  AssessmentEntity copyWith({
    String? nickname,
    String? stationId,
    int? score,
    String? description,
    DateTime? createdAt,
  }) {
    return AssessmentEntity(
      nickname: nickname ?? this.nickname,
      stationId: stationId ?? this.stationId,
      score: score ?? this.score,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    nickname,
    stationId,
    score,
    description,
    createdAt,
  ];
}
