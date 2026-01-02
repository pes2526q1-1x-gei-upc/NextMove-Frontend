import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';
import 'dart:math' as math;

class TrackValidationResult {
  final bool isValid;
  final String? reason;

  TrackValidationResult({
    required this.isValid,
    this.reason,
  });
}

class TrackValidator {
  static const double _maxRealisticSpeedKmH = 55.0; 
  static const double _maxDistanceBetweenPointsMeters = 500.0;
  static const int _minPointsRequired = 4;
  static const double _minTotalDistanceMeters = 10.0;

  TrackValidationResult validate(RecordedTrack track) {
    if (track.points.length < _minPointsRequired) {
      return TrackValidationResult(
        isValid: false,
        reason: 'La ruta debe tener al menos $_minPointsRequired puntos',
      );
    }

    if (track.totalDistanceMeters < _minTotalDistanceMeters) {
      return TrackValidationResult(
        isValid: false,
        reason: 'La ruta no muestra movimiento significativo',
      );
    }

    for (int i = 1; i < track.points.length; i++) {
      if (track.points[i].timestamp.isBefore(track.points[i - 1].timestamp)) {
        return TrackValidationResult(
          isValid: false,
          reason: 'Datos temporales inconsistentes',
        );
      }
    }

    int identicalPoints = 0;
    int suspiciousJumps = 0;

    for (int i = 1; i < track.points.length; i++) {
      final prev = track.points[i - 1];
      final current = track.points[i];

      final distance = _calculateDistance(prev.location, current.location);
      final timeDiff = current.timestamp.difference(prev.timestamp);

      if (_arePointsIdentical(prev.location, current.location)) {
        identicalPoints++;
      }

      if (distance > _maxDistanceBetweenPointsMeters && timeDiff.inSeconds < 10) {
        suspiciousJumps++;
      }

      if (current.speed > _maxRealisticSpeedKmH) {
        return TrackValidationResult(
          isValid: false,
          reason: 'Velocidad imposible detectada: ${current.speed.toStringAsFixed(1)} km/h',
        );
      }
    }

    final identicalRatio = identicalPoints / track.points.length;
    if (identicalRatio > 0.6) {
      return TrackValidationResult(
        isValid: false,
        reason: 'Patrón de GPS sospechoso detectado',
      );
    }

    if (suspiciousJumps > track.points.length * 0.1) {
      return TrackValidationResult(
        isValid: false,
        reason: 'Movimientos imposibles detectados',
      );
    }

    if (track.maxSpeedKmH > _maxRealisticSpeedKmH) {
      return TrackValidationResult(
        isValid: false,
        reason: 'Velocidad máxima imposible',
      );
    }

    return TrackValidationResult(isValid: true);
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const earthRadius = 6371000.0;
    final lat1 = point1.latitude * math.pi / 180;
    final lat2 = point2.latitude * math.pi / 180;
    final deltaLat = (point2.latitude - point1.latitude) * math.pi / 180;
    final deltaLng = (point2.longitude - point1.longitude) * math.pi / 180;

    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
        math.sin(deltaLng / 2) * math.sin(deltaLng / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  bool _arePointsIdentical(LatLng point1, LatLng point2) {
    const tolerance = 0.0000001;
    return (point1.latitude - point2.latitude).abs() < tolerance &&
           (point1.longitude - point2.longitude).abs() < tolerance;
  }
}