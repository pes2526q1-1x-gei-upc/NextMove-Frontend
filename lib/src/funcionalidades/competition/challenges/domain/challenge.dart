import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/company.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/trophy.dart';

class Challenge {
  final String id;
  final String name; // name és clau alternativa (unique + not null)
  final Company company;
  final String description;
  final double distance;
  final int points;
  final DateTime startingDate;
  final DateTime endingDate;
  final String? photo;
  final bool isCompleted;

  final Trophy trophy;

  Challenge({
    required this.id,
    required this.name,
    required this.company,
    required this.description,
    required this.distance,
    required this.points,
    required this.startingDate,
    required this.endingDate,
    this.photo,
    required this.isCompleted,
  }) : trophy = Trophy.fromChallengeName(name);

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
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
      isCompleted: json['is_completed'] as bool,
    );
  }

  Challenge copyWith({
    String? id,
    String? name,
    Company? company,
    String? description,
    double? distance,
    int? points,
    DateTime? startingDate,
    DateTime? endingDate,
    String? photo,
    bool? isCompleted,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      description: description ?? this.description,
      distance: distance ?? this.distance,
      points: points ?? this.points,
      startingDate: startingDate ?? this.startingDate,
      endingDate: endingDate ?? this.endingDate,
      photo: photo ?? this.photo,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
