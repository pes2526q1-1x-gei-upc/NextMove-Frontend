import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/shared/domain/track_statistics.dart';

class TrackPoint {
  final LatLng location;
  final double altitude;
  final DateTime timestamp;
  // speed between the current point and the last one; the first point has a speed of 0.
  late double speed;

  TrackPoint({
    required this.location,
    required this.altitude,
    required this.timestamp,
  });
}

class RecordedTrack implements TrackStatistics {
  final DateTime startTime = DateTime.now(); // set at the beginning
  late DateTime endTime = startTime;

  // points are being added as the route is recorded; same for the calculation of statistics
  List<TrackPoint> points = [];
  double totalDistanceMeters = 0.0;
  double averageSpeedKmH = 0.0;
  double maxSpeedKmH = 0.0;
  Duration totalTime = Duration.zero;
  double elevationGainMeters = 0.0;
  double elevationLossMeters = 0.0;

  bool suspectedFraud = false;
  
  double co2SavedKG = 0.0;
  double kcalBurned = 0.0;

  TrackPoint get startPoint => points.first;
  TrackPoint get endPoint => points.last;

  void addPoint(TrackPoint newPoint) {
    double speedKmH = 0.0;
    if (points.isNotEmpty) {
      final lastPoint = points.last;
      final distanceMeters = Geolocator.distanceBetween(
        lastPoint.location.latitude,
        lastPoint.location.longitude,
        newPoint.location.latitude,
        newPoint.location.longitude,
      );
      final timeDiffMillis = newPoint.timestamp
          .difference(lastPoint.timestamp)
          .inMilliseconds;
      speedKmH = timeDiffMillis == 0 ? 0.0 : (distanceMeters / timeDiffMillis) * 3600; // km/h

      totalDistanceMeters += distanceMeters;

      totalTime += Duration(milliseconds: timeDiffMillis);

      averageSpeedKmH =
          totalTime.inSeconds == 0 ? 0.0 : (totalDistanceMeters / totalTime.inSeconds) * 3.6; // km/h

      if (speedKmH > maxSpeedKmH) {
        maxSpeedKmH = speedKmH;
      }

      final elevationDiff = newPoint.altitude - lastPoint.altitude;
      if (elevationDiff > 0) {
        elevationGainMeters += elevationDiff;
      } else {
        elevationLossMeters += -elevationDiff;
      }

      co2SavedKG = (totalDistanceMeters / 1000) * 0.192; // 0.192 kg CO2/km
      kcalBurned = (totalDistanceMeters / 1000) * 40; // 40 kcal/km
    }
    newPoint.speed = speedKmH;
    points.add(newPoint);
    endTime = newPoint.timestamp;
  }

  @override
  String toString() {
    final attributes = {
      'startTime': startTime,
      'endTime': endTime,
      'suspectedFraud': suspectedFraud,
      'totalDistanceMeters': totalDistanceMeters,
      'averageSpeedKmH': averageSpeedKmH,
      'maxSpeedKmH': maxSpeedKmH,
      'totalTime': totalTime,
      'elevationGainMeters': elevationGainMeters,
      'elevationLossMeters': elevationLossMeters,
      'co2SavedKG': co2SavedKG,
      'kcalBurned': kcalBurned,
      'number of points': points.length,
    };
    return attributes.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}
