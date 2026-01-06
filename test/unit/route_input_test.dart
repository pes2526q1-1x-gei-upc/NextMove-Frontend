import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/shared/domain/route_input.dart';
import 'package:nextmove_app/src/shared/enums/route_input_enums.dart';

void main() {
  group('RouteInput', () {
    const origin = LatLng(41.3851, 2.1734);
    const destination = LatLng(41.4036, 2.1744);
    final mode = TravelModeEnum.DRIVE;
    final routingPreference = RoutingPreferenceEnum.TRAFFIC_AWARE;
    const languageCode = 'es';

    late RouteInput routeInput;

    setUp(() {
      routeInput = RouteInput(
        origin: origin,
        destination: destination,
        mode: mode,
        routingPreference: routingPreference,
        languageCode: languageCode,
      );
    });

    test('should store origin correctly', () {
      expect(routeInput.origin, origin);
    });

    test('should store destination correctly', () {
      expect(routeInput.destination, destination);
    });

    test('should store mode correctly', () {
      expect(routeInput.mode, mode);
    });

    test('should store routingPreference correctly', () {
      expect(routeInput.routingPreference, routingPreference);
    });

    test('should store languageCode correctly', () {
      expect(routeInput.languageCode, languageCode);
    });

    test('should handle null languageCode', () {
      final routeInputWithoutLang = RouteInput(
        origin: origin,
        destination: destination,
        mode: mode,
        routingPreference: routingPreference,
      );
      expect(routeInputWithoutLang.languageCode, isNull);
    });

    group('toVariables', () {
      test('should return correct map with all fields', () {
        final variables = routeInput.toVariables();

        expect(variables, {
          'origin': {
            'latitude': origin.latitude,
            'longitude': origin.longitude,
          },
          'destination': {
            'latitude': destination.latitude,
            'longitude': destination.longitude,
          },
          'travelMode': mode.name,
          'routingPreference': routingPreference.name,
          'languageCode': languageCode,
        });
      });

      test('should use default languageCode when null', () {
        final routeInputWithoutLang = RouteInput(
          origin: origin,
          destination: destination,
          mode: mode,
          routingPreference: routingPreference,
        );
        final variables = routeInputWithoutLang.toVariables();

        expect(variables['languageCode'], 'es');
      });

      test('should handle different travel modes', () {
        final bicycleInput = RouteInput(
          origin: origin,
          destination: destination,
          mode: TravelModeEnum.BICYCLE,
          routingPreference: routingPreference,
        );
        final variables = bicycleInput.toVariables();

        expect(variables['travelMode'], 'BICYCLE');
      });

      test('should handle different routing preferences', () {
        final trafficUnawareInput = RouteInput(
          origin: origin,
          destination: destination,
          mode: mode,
          routingPreference: RoutingPreferenceEnum.TRAFFIC_UNAWARE,
        );
        final variables = trafficUnawareInput.toVariables();

        expect(variables['routingPreference'], 'TRAFFIC_UNAWARE');
      });
    });
  });
}