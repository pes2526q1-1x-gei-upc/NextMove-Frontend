import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/company.dart';

class EnrolledChallenge extends Challenge {
  final int completed;
  final double totalDistance;
  final double currentDistance;

  EnrolledChallenge({
    required super.id,
    required super.name,
    required super.company,
    required super.description,
    required super.distance,
    required super.points,
    required super.startingDate,
    required super.endingDate,
    super.photo,
    required this.completed,
    required this.totalDistance,
    required this.currentDistance,
  });

  factory EnrolledChallenge.fromJson(Map<String, dynamic> json) {
    return EnrolledChallenge(
      id: json['id'] as String,
      name: json['name'] as String,
      company: Company.fromJson(json['company'] as Map<String, dynamic>),
      description: json['description'] as String,
      distance: ((json['distance'] as num).toDouble()) / 1000, // meters to kilometers
      points: json['points'] as int,
      startingDate: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['starting_date'] as String),
      ),
      endingDate: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['ending_date'] as String),
      ),
      photo: json['photo'] as String?,
      completed: json['completed'] as int? ?? 0,
      totalDistance: ((json['total_distance'] as num?)?.toDouble() ?? 0.0) / 1000, // meters to kilometers
      currentDistance: ((json['current_distance'] as num?)?.toDouble() ?? 0.0) / 1000, // meters to kilometers
    );
  }

  @override
  String toString() {
    return 'EnrolledChallenge(id: $id, name: $name, completed: $completed, '
        'totalDistance: $totalDistance, currentDistance: $currentDistance)';
  }
}
