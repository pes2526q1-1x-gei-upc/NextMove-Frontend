import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/company.dart';

class Challenge {
  final String name; // name és clau alternativa (unique + not null)
  final Company company;
  final String description;
  final double distance;
  final int points;
  final DateTime startingDate;
  final DateTime endingDate;
  final bool isEnrolled;
  final String? photo;

  Challenge({
    required this.name,
    required this.company,
    required this.description,
    required this.distance,
    required this.points,
    required this.startingDate,
    required this.endingDate,
    required this.isEnrolled,
    this.photo,
  });

  factory Challenge.fromJson(Map<String, dynamic> json, List<String> enrolledChallengesNames) {
    return Challenge(
      name: json['name'] as String,
      company: Company.fromJson(json['company'] as Map<String, dynamic>),
      description: json['description'] as String,
      distance: (json['distance'] as num).toDouble(),
      points: json['points'] as int,
      startingDate: DateTime.fromMillisecondsSinceEpoch(int.parse(json['starting_date'] as String)),
      endingDate: DateTime.fromMillisecondsSinceEpoch(int.parse(json['ending_date'] as String)),
      isEnrolled: enrolledChallengesNames.contains(json['name'] as String),
    );
  }
}