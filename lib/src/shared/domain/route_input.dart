import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/shared/enums/route_input_enums.dart';

class RouteInput {
  final LatLng origin;
  final LatLng destination;
  final TravelMode mode;
  final RoutingPreference routingPreference;

  RouteInput({
    required this.origin,
    required this.destination,
    required this.mode,
    required this.routingPreference,
  });

  Map<String, dynamic> toVariables() {
    return {
      'origin': {
        'latitude': origin.latitude,
        'longitude': origin.longitude,
      },
      'destination': {
        'latitude': destination.latitude,
        'longitude': destination.longitude,
      },
      'mode': mode.name,
      'routingPreference': routingPreference.name,
    };
  }

}