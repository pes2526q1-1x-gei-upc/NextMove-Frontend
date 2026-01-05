class RankingEntry {
  final String email;
  final String nickname;
  final int? numberOfRoutes;
  final double? distance;
  final double? elevationGain;
  final double? caloriesBurned;
  final double? co2Saved;
  final int? challengesParticipated;
  final int? challengesCompleted;
  final int? points;

  // final int? score;

  RankingEntry({
    required this.email,
    required this.nickname,
    // this.score,
    this.numberOfRoutes,
    this.distance,
    this.elevationGain,
    this.caloriesBurned,
    this.co2Saved,
    this.challengesParticipated,
    this.challengesCompleted,
    this.points,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      numberOfRoutes: json['num_rutas'] as int?,
      distance: (json['km_recorridos'] as num?)?.toDouble(),
      elevationGain: (json['elevacion_positiva'] as num?)?.toDouble(),
      caloriesBurned: (json['calorias_quemadas'] as num?)?.toDouble(),
      co2Saved: (json['co2_ahorrado'] as num?)?.toDouble(),
      challengesParticipated: json['num_retos_participados'] as int?,
      challengesCompleted: json['num_retos_completados'] as int?,
      points: json['puntos_totales'] as int?,
    );
  }
}
