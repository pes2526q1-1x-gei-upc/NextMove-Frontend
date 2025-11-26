import 'package:google_maps_flutter/google_maps_flutter.dart';

class RecordedRoute {
  final String id;
  final String userEmail;
  final double distance;
  final double? averageSpeed;
  final double? co2;
  final double? kcal;
  final LatLng? origin;
  final LatLng? destination;
  final DateTime timestamp;

  RecordedRoute({
    required this.id,
    required this.userEmail,
    required this.distance,
    this.averageSpeed,
    this.co2,
    this.kcal,
    this.origin,
    this.destination,
    required this.timestamp,
  });

  factory RecordedRoute.fromJson(Map<String, dynamic> data) {
    return RecordedRoute(
      id: data['id'] as String,
      userEmail: data['user_email'] as String,
      distance: (data['distancia'] as num).toDouble(),
      averageSpeed: data['velocidad_media'] != null
          ? (data['velocidad_media'] as num).toDouble()
          : null,
      co2: data['co2'] != null ? (data['co2'] as num).toDouble() : null,
      kcal: data['kcal'] != null ? (data['kcal'] as num).toDouble() : null,
      origin: data['origen'] != null
          ? LatLng(
              (data['origen']['latitude'] as num).toDouble(),
              (data['origen']['longitude'] as num).toDouble(),
            )
          : null,
      destination: data['destino'] != null
          ? LatLng(
              (data['destino']['latitude'] as num).toDouble(),
              (data['destino']['longitude'] as num).toDouble(),
            )
          : null,
      timestamp: DateTime.parse(data['fecha_recorrido'] as String),
    );
  }
}