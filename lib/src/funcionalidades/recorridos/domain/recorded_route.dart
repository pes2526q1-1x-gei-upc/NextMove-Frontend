import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class RecordedRoute {
  final String id;
  final String userEmail;
  final double distance;
  final double? averageSpeed;
  final double? maxSpeed;
  final double? co2;
  final double? kcal;
  final double? elevationGain;
  final double? elevationLoss;
  final LatLng? origin;
  final LatLng? destination;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime timestamp;

  RecordedRoute({
    required this.id,
    required this.userEmail,
    required this.distance,
    this.averageSpeed,
    this.maxSpeed,
    this.co2,
    this.kcal,
    this.elevationGain,
    this.elevationLoss,
    this.origin,
    this.destination,
    this.startTime,
    this.endTime,
    required this.timestamp,
  });

  factory RecordedRoute.fromJson(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('RecordedRoute.fromJson data: $data');
    }
    return RecordedRoute(
      id: data['id'] as String,
      userEmail: data['user_email'] as String,
      distance: (data['distancia'] as num).toDouble(),
      averageSpeed: data['velocidad_media'] != null
          ? (data['velocidad_media'] as num).toDouble()
          : null,
      maxSpeed: data['velocidad_maxima'] != null
          ? (data['velocidad_maxima'] as num).toDouble()
          : null,
      co2: data['co2'] != null ? (data['co2'] as num).toDouble() : null,
      kcal: data['kcal'] != null ? (data['kcal'] as num).toDouble() : null,
      elevationGain: data['elevacion_positiva'] != null
          ? (data['elevacion_positiva'] as num).toDouble()
          : null,
      elevationLoss: data['elevacion_negativa'] != null
          ? (data['elevacion_negativa'] as num).toDouble()
          : null,
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
      startTime: data['tiempo_inicio'] != null
          ? DateFormat('dd/MM/yyyy HH:mm:ss').parse(data['tiempo_inicio'] as String)
          : null,
      endTime: data['tiempo_fin'] != null
          ? DateFormat('dd/MM/yyyy HH:mm:ss').parse(data['tiempo_fin'] as String)
          : null,
      timestamp: DateFormat('dd/MM/yyyy HH:mm:ss').parse(data['fecha_recorrido'] as String),    
    );
  }
}
