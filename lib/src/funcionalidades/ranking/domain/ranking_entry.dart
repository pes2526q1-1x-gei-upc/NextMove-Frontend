class RankingEntry {
  final String email;
  final int? numberOfRoutes;
  final double? distance;
  final double? elevationGain;
  final double? caloriesBurned;
  final double? co2Saved;

  final int? score;

  RankingEntry({
    required this.email,
    this.score,
    this.numberOfRoutes,
    this.distance,
    this.elevationGain,
    this.caloriesBurned,
    this.co2Saved,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      email: json['email'] as String,
      score: json['score'] as int?,
      numberOfRoutes: json['num_rutas'] as int?,
      distance: json['km_recorridos'] as double?,
      elevationGain: json['elevacion_positiva'] as double?,
      caloriesBurned: json['calorias_quemadas'] as double?,
      co2Saved: json['co2_ahorrado'] as double?,
    );
  }
}
