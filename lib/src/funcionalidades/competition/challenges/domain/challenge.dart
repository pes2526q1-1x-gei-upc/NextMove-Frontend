class Challenge {
  final String description;
  final double distance;
  final DateTime endingDate;
  final String name;
  final int points;
  final DateTime startingDate;

  Challenge({
    required this.description,
    required this.distance,
    required this.endingDate,
    required this.name,
    required this.points,
    required this.startingDate,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      description: json['description'] as String,
      distance: (json['distance'] as num).toDouble(),
      endingDate: DateTime.fromMillisecondsSinceEpoch(int.parse(json['ending_date'] as String)),
      name: json['name'] as String,
      points: json['points'] as int,
      startingDate: DateTime.fromMillisecondsSinceEpoch(int.parse(json['starting_date'] as String)),
    );
  }
}