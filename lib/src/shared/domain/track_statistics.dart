import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';

abstract class TrackStatistics {
  double get totalDistanceMeters;
  double get averageSpeedKmH;
  double get maxSpeedKmH;
  double get co2SavedKG;
  double get kcalBurned;
  double get elevationGainMeters;
  double get elevationLossMeters;
}

class RecordedTrackWrapper implements TrackStatistics {
  final RecordedTrack track;

  RecordedTrackWrapper(this.track);

  @override
  double get totalDistanceMeters => track.totalDistanceMeters;

  @override
  double get averageSpeedKmH => track.averageSpeedKmH;

  @override
  double get maxSpeedKmH => track.maxSpeedKmH;

  @override
  double get co2SavedKG => track.co2SavedKG;

  @override
  double get kcalBurned => track.kcalBurned;

  @override
  double get elevationGainMeters => track.elevationGainMeters;

  @override
  double get elevationLossMeters => track.elevationLossMeters;
}

class RecordedRouteWrapper implements TrackStatistics {
  final RecordedRoute route;

  RecordedRouteWrapper(this.route);

  @override
  double get totalDistanceMeters => route.distance;

  @override
  double get averageSpeedKmH => route.averageSpeed ?? 0.0;

  @override
  double get maxSpeedKmH => route.maxSpeed ?? 0.0;

  @override
  double get co2SavedKG => route.co2 ?? 0.0;

  @override
  double get kcalBurned => route.kcal ?? 0.0;

  @override
  double get elevationGainMeters => route.elevationGain ?? 0.0;

  @override
  double get elevationLossMeters => route.elevationLoss ?? 0.0;
}