import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationRoute {
  final String distance;
  final int distanceMeters;
  final String duration;
  final int durationSeconds;
  final String polyline;
  final bool isEcoFriendly;
  final List<String> routeLabels;
  final LatLng? startLocation;
  final LatLng? endLocation;
  final RouteViewport? viewport;
  final TravelAdvisory? travelAdvisory;
  final List<RouteStep> steps;

  NavigationRoute({
    required this.distance,
    required this.distanceMeters,
    required this.duration,
    required this.durationSeconds,
    required this.polyline,
    required this.isEcoFriendly,
    required this.routeLabels,
    this.startLocation,
    this.endLocation,
    this.viewport,
    this.travelAdvisory,
    required this.steps,
  });

  factory NavigationRoute.fromJson(Map<String, dynamic> json) {
    return NavigationRoute(
      distance: json['distance'] as String,
      distanceMeters: json['distanceMeters'] as int,
      duration: json['duration'] as String,
      durationSeconds: json['durationSeconds'] as int,
      polyline: json['polyline'] as String,
      isEcoFriendly: json['isEcoFriendly'] as bool,
      routeLabels: List<String>.from(json['routeLabels'] ?? []),
      startLocation: json['startLocation'] != null
          ? LatLng(
              json['startLocation']['latitude'] as double,
              json['startLocation']['longitude'] as double,
            )
          : null,
      endLocation: json['endLocation'] != null
          ? LatLng(
              json['endLocation']['latitude'] as double,
              json['endLocation']['longitude'] as double,
            )
          : null,
      viewport: json['viewport'] != null
          ? RouteViewport.fromJson(json['viewport'] as Map<String, dynamic>)
          : null,
      travelAdvisory: json['travelAdvisory'] != null
          ? TravelAdvisory.fromJson(json['travelAdvisory'] as Map<String, dynamic>)
          : null,
      steps: (json['steps'] as List<dynamic>?)
              ?.map((step) => RouteStep.fromJson(step as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RouteViewport {
  final LatLng low;
  final LatLng high;

  RouteViewport({
    required this.low,
    required this.high,
  });

  factory RouteViewport.fromJson(Map<String, dynamic> json) {
    return RouteViewport(
      low: LatLng(
        json['low']['latitude'] as double,
        json['low']['longitude'] as double,
      ),
      high: LatLng(
        json['high']['latitude'] as double,
        json['high']['longitude'] as double,
      ),
    );
  }
}

class TravelAdvisory {
  final bool hasTollRoads;
  final String? estimatedTollPrice;
  final String? fuelConsumption;

  TravelAdvisory({
    required this.hasTollRoads,
    this.estimatedTollPrice,
    this.fuelConsumption,
  });

  factory TravelAdvisory.fromJson(Map<String, dynamic> json) {
    return TravelAdvisory(
      hasTollRoads: json['hasTollRoads'] as bool,
      estimatedTollPrice: json['estimatedTollPrice'] as String?,
      fuelConsumption: json['fuelConsumption'] as String?,
    );
  }
}

class RouteStep {
  final String instruction;
  final String distance;
  final int distanceMeters;
  final String duration;
  final int durationSeconds;
  final LatLng? startLocation;
  final LatLng? endLocation;
  final String? polyline;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.distanceMeters,
    required this.duration,
    required this.durationSeconds,
    this.startLocation,
    this.endLocation,
    this.polyline,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['instruction'] as String,
      distance: json['distance'] as String,
      distanceMeters: json['distanceMeters'] as int,
      duration: json['duration'] as String,
      durationSeconds: json['durationSeconds'] as int,
      startLocation: json['startLocation'] != null
          ? LatLng(
              json['startLocation']['latitude'] as double,
              json['startLocation']['longitude'] as double,
            )
          : null,
      endLocation: json['endLocation'] != null
          ? LatLng(
              json['endLocation']['latitude'] as double,
              json['endLocation']['longitude'] as double,
            )
          : null,
      polyline: json['polyline'] as String?,
    );
  }
}
