import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

class RecordedTrack {
  final DateTime startTime = DateTime.now(); // set at the beginning
  late DateTime endTime; // set at the end
  late bool suspectedFraud; // TODO: final??

  // points are being added as the route is recorded; same for the calculation of statistics
  List<TrackPoint> points = [];
  double totalDistanceMeters = 0.0;
  double averageSpeedKmH = 0.0;
  double maxSpeedKmH = 0.0;
  Duration totalTime = Duration.zero;
  double elevationGainMeters = 0.0;
  double elevationLossMeters = 0.0;

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
      speedKmH = (distanceMeters / timeDiffMillis) * 3600; // km/h
      totalDistanceMeters += distanceMeters;
      totalTime += Duration(milliseconds: timeDiffMillis);
      averageSpeedKmH =
          (totalDistanceMeters / totalTime.inSeconds) * 3.6; // km/h
      if (speedKmH > maxSpeedKmH) {
        maxSpeedKmH = speedKmH;
      }
      final elevationDiff = newPoint.altitude - lastPoint.altitude;
      if (elevationDiff > 0) {
        elevationGainMeters += elevationDiff;
      } else {
        elevationLossMeters += -elevationDiff;
      }
    }
    newPoint.speed = speedKmH;
    points.add(newPoint);
  }

  @override
  String toString() {
    return 'startTime: $startTime\nendTime: $endTime\ntotalDistanceMeters: $totalDistanceMeters\naverageSpeedKmH: $averageSpeedKmH\nmaxSpeedKmH: $maxSpeedKmH\ntotalTime: $totalTime\nelevationGainMeters: $elevationGainMeters\nelevationLossMeters: $elevationLossMeters\nnumber of points: ${points.length}';
  }
}
