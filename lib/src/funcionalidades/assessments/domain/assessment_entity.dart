import 'package:equatable/equatable.dart';

class AssessmentEntity extends Equatable {
  final String nickname;
  final String station_id;
  final int score;
  final String description;
  final DateTime created_at;

  const AssessmentEntity({
    required this.nickname,
    required this.station_id,
    required this.score,
    required this.description,
    required this.created_at,
  });

  AssessmentEntity copyWith({
    String? nickname,
    String? station_id,
    int? score,
    String? description,
    DateTime? created_at,
  }) {
    return AssessmentEntity(
      nickname: nickname ?? this.nickname,
      station_id: station_id ?? this.station_id,
      score: score ?? this.score,
      description: description ?? this.description,
      created_at: created_at ?? this.created_at,
    );
  }

  @override
  List<Object?> get props => [
    nickname,
    station_id,
    score,
    description,
    created_at,
  ];
}
