import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/company.dart';

class Challenge {
  final String name; // name és clau alternativa (unique + not null)
  final Company company;
  final String description;
  final double distance;
  final DateTime endingDate;
  final int points;
  final DateTime startingDate;
  final String? photo;

  Challenge({
    required this.name,
    required this.company,
    required this.description,
    required this.distance,
    required this.endingDate,
    required this.points,
    required this.startingDate,
    this.photo,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      name: json['name'] as String,
      company: Company.fromJson(json['company'] as Map<String, dynamic>),
      description: json['description'] as String,
      distance: (json['distance'] as num).toDouble(),
      endingDate: DateTime.fromMillisecondsSinceEpoch(int.parse(json['ending_date'] as String)),
      points: json['points'] as int,
      startingDate: DateTime.fromMillisecondsSinceEpoch(int.parse(json['starting_date'] as String)),
    );
  }
}