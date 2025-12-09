import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recording_track.dart';

class RecordedTrack extends RecordingTrack {
  final String id;
  final String userEmail;

  late DateTime timestamp;

  RecordedTrack({
    required this.id,
    required this.userEmail,
    required double totalDistanceMeters,
    double? averageSpeedKmH,
    double? maxSpeedKmH,
    double? co2SavedKG,
    double? kcalBurned,
    double? elevationGainMeters,
    double? elevationLossMeters,
    LatLng? origin,
    LatLng? destination,
    DateTime? startTime,
    DateTime? endTime,
    required this.timestamp,
  }) : super() {
    this.totalDistanceMeters = totalDistanceMeters;
    this.averageSpeedKmH = averageSpeedKmH ?? 0.0;
    this.maxSpeedKmH = maxSpeedKmH ?? 0.0;
    this.co2SavedKG = co2SavedKG ?? 0.0;
    this.kcalBurned = kcalBurned ?? 0.0;
    this.elevationGainMeters = elevationGainMeters ?? 0.0;
    this.elevationLossMeters = elevationLossMeters ?? 0.0;
    this.origin = origin ?? LatLng(0.0, 0.0);
    this.destination = destination ?? LatLng(0.0, 0.0);
    this.startTime = startTime ?? DateTime.now();
    this.endTime = endTime ?? this.startTime;
  }

  factory RecordedTrack.fromJson(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('RecordedTrack.fromJson data: $data');
    }
    return RecordedTrack(
      id: data['id'] as String,
      userEmail: data['user_email'] as String,
      totalDistanceMeters: (data['distancia'] as num).toDouble(),
      averageSpeedKmH: data['velocidad_media'] != null
          ? (data['velocidad_media'] as num).toDouble()
          : null,
      maxSpeedKmH: data['velocidad_maxima'] != null
          ? (data['velocidad_maxima'] as num).toDouble()
          : null,
      co2SavedKG: data['co2'] != null ? (data['co2'] as num).toDouble() : null,
      kcalBurned: data['kcal'] != null
          ? (data['kcal'] as num).toDouble()
          : null,
      elevationGainMeters: data['elevacion_positiva'] != null
          ? (data['elevacion_positiva'] as num).toDouble()
          : null,
      elevationLossMeters: data['elevacion_negativa'] != null
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
          ? DateFormat(
              'dd/MM/yyyy HH:mm:ss',
            ).parse(data['tiempo_inicio'] as String)
          : null,
      endTime: data['tiempo_fin'] != null
          ? DateFormat(
              'dd/MM/yyyy HH:mm:ss',
            ).parse(data['tiempo_fin'] as String)
          : null,
      timestamp: DateFormat(
        'dd/MM/yyyy HH:mm:ss',
      ).parse(data['fecha_recorrido'] as String),
    );
  }
}
