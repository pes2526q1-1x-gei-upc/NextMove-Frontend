import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/navigation_route.dart';

void main() {
  group('NavigationRoute', () {
    test('should create NavigationRoute from valid JSON', () {
      final json = {
        'distance': '5.2 km',
        'distanceMeters': 5200,
        'duration': '15 min',
        'durationSeconds': 900,
        'polyline': 'encoded_polyline_string',
        'isEcoFriendly': true,
        'routeLabels': ['eco', 'fast'],
        'startLocation': {
          'latitude': 41.3851,
          'longitude': 2.1734,
        },
        'endLocation': {
          'latitude': 41.3871,
          'longitude': 2.1754,
        },
        'viewport': {
          'low': {
            'latitude': 41.3800,
            'longitude': 2.1700,
          },
          'high': {
            'latitude': 41.3900,
            'longitude': 2.1800,
          },
        },
        'travelAdvisory': {
          'hasTollRoads': false,
          'estimatedTollPrice': null,
          'fuelConsumption': '0.5 L',
        },
        'steps': [
          {
            'instruction': 'Head north',
            'distance': '100 m',
            'distanceMeters': 100,
            'duration': '1 min',
            'durationSeconds': 60,
            'startLocation': {
              'latitude': 41.3851,
              'longitude': 2.1734,
            },
            'endLocation': {
              'latitude': 41.3861,
              'longitude': 2.1734,
            },
            'polyline': 'step_polyline',
          },
        ],
      };

      final route = NavigationRoute.fromJson(json);

      expect(route.distance, '5.2 km');
      expect(route.distanceMeters, 5200);
      expect(route.duration, '15 min');
      expect(route.durationSeconds, 900);
      expect(route.polyline, 'encoded_polyline_string');
      expect(route.isEcoFriendly, true);
      expect(route.routeLabels, ['eco', 'fast']);
      expect(route.startLocation, LatLng(41.3851, 2.1734));
      expect(route.endLocation, LatLng(41.3871, 2.1754));
      expect(route.viewport, isNotNull);
      expect(route.travelAdvisory, isNotNull);
      expect(route.steps.length, 1);
    });

    test('should handle null optional fields', () {
      final json = {
        'distance': '5.2 km',
        'distanceMeters': 5200,
        'duration': '15 min',
        'durationSeconds': 900,
        'polyline': 'encoded_polyline_string',
        'isEcoFriendly': false,
        'routeLabels': [],
        'steps': [],
      };

      final route = NavigationRoute.fromJson(json);

      expect(route.startLocation, isNull);
      expect(route.endLocation, isNull);
      expect(route.viewport, isNull);
      expect(route.travelAdvisory, isNull);
      expect(route.steps, isEmpty);
    });

    test('should handle empty routeLabels', () {
      final json = {
        'distance': '5.2 km',
        'distanceMeters': 5200,
        'duration': '15 min',
        'durationSeconds': 900,
        'polyline': 'encoded_polyline_string',
        'isEcoFriendly': false,
        'steps': [],
      };

      final route = NavigationRoute.fromJson(json);

      expect(route.routeLabels, isEmpty);
    });
  });

  group('RouteViewport', () {
    test('should create RouteViewport from valid JSON', () {
      final json = {
        'low': {
          'latitude': 41.3800,
          'longitude': 2.1700,
        },
        'high': {
          'latitude': 41.3900,
          'longitude': 2.1800,
        },
      };

      final viewport = RouteViewport.fromJson(json);

      expect(viewport.low, LatLng(41.3800, 2.1700));
      expect(viewport.high, LatLng(41.3900, 2.1800));
    });
  });

  group('TravelAdvisory', () {
    test('should create TravelAdvisory from valid JSON with all fields', () {
      final json = {
        'hasTollRoads': true,
        'estimatedTollPrice': '5.50 EUR',
        'fuelConsumption': '2.5 L',
      };

      final advisory = TravelAdvisory.fromJson(json);

      expect(advisory.hasTollRoads, true);
      expect(advisory.estimatedTollPrice, '5.50 EUR');
      expect(advisory.fuelConsumption, '2.5 L');
    });

    test('should create TravelAdvisory with null optional fields', () {
      final json = {
        'hasTollRoads': false,
      };

      final advisory = TravelAdvisory.fromJson(json);

      expect(advisory.hasTollRoads, false);
      expect(advisory.estimatedTollPrice, isNull);
      expect(advisory.fuelConsumption, isNull);
    });
  });

  group('RouteStep', () {
    test('should create RouteStep from valid JSON', () {
      final json = {
        'instruction': 'Turn left',
        'distance': '200 m',
        'distanceMeters': 200,
        'duration': '2 min',
        'durationSeconds': 120,
        'startLocation': {
          'latitude': 41.3851,
          'longitude': 2.1734,
        },
        'endLocation': {
          'latitude': 41.3871,
          'longitude': 2.1754,
        },
        'polyline': 'step_polyline',
      };

      final step = RouteStep.fromJson(json);

      expect(step.instruction, 'Turn left');
      expect(step.distance, '200 m');
      expect(step.distanceMeters, 200);
      expect(step.duration, '2 min');
      expect(step.durationSeconds, 120);
      expect(step.startLocation, LatLng(41.3851, 2.1734));
      expect(step.endLocation, LatLng(41.3871, 2.1754));
      expect(step.polyline, 'step_polyline');
    });

    test('should handle null optional fields in RouteStep', () {
      final json = {
        'instruction': 'Continue straight',
        'distance': '100 m',
        'distanceMeters': 100,
        'duration': '1 min',
        'durationSeconds': 60,
      };

      final step = RouteStep.fromJson(json);

      expect(step.startLocation, isNull);
      expect(step.endLocation, isNull);
      expect(step.polyline, isNull);
    });
  });
}

