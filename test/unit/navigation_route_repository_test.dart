import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/dataproviders/navigation_route_provider.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/repositories/navigation_route_repository.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/navigation_route.dart';
import 'package:nextmove_app/src/shared/domain/route_input.dart';
import 'package:nextmove_app/src/shared/enums/route_input_enums.dart';

class MockNavigationRouteProvider extends Mock implements NavigationRouteDataProvider {}

void main() {
  late MockNavigationRouteProvider mockProvider;
  late NavigationRouteRepository repository;

  setUp(() {
    mockProvider = MockNavigationRouteProvider();
    repository = NavigationRouteRepository(navigationRouteProvider: mockProvider);
  });

  tearDown(() {
    reset(mockProvider);
  });

  RouteInput createRouteInput() {
    return RouteInput(
      origin: LatLng(41.3851, 2.1734),
      destination: LatLng(41.3871, 2.1754),
      mode: TravelModeEnum.BICYCLE,
      routingPreference: RoutingPreferenceEnum.TRAFFIC_UNAWARE,
      languageCode: 'es',
    );
  }

  NavigationRoute createMockRoute() {
    return NavigationRoute(
      distance: '5.2 km',
      distanceMeters: 5200,
      duration: '15 min',
      durationSeconds: 900,
      polyline: 'encoded_polyline_string',
      isEcoFriendly: true,
      routeLabels: ['eco', 'fast'],
      startLocation: LatLng(41.3851, 2.1734),
      endLocation: LatLng(41.3871, 2.1754),
      steps: [],
    );
  }

  group('NavigationRouteRepository', () {
    test('should return Right with NavigationRoute on successful fetch', () async {
      final routeInput = createRouteInput();
      final mockRoute = createMockRoute();
      when(() => mockProvider.computeRoute(routeInput))
          .thenAnswer((_) async => mockRoute);

      final result = await repository.fetchNavigationRoute(routeInput);

      expect(result, isA<Right<Failure, NavigationRoute>>());
      final route = result.getOrElse(() => throw Exception('Expected Right'));
      expect(route.distance, '5.2 km');
      expect(route.distanceMeters, 5200);
      expect(route.isEcoFriendly, true);
      verify(() => mockProvider.computeRoute(routeInput)).called(1);
    });

    test('should return ServerFailure when ServerException is thrown', () async {
      final routeInput = createRouteInput();
      when(() => mockProvider.computeRoute(routeInput))
          .thenThrow(ServerException('Server error'));

      final result = await repository.fetchNavigationRoute(routeInput);

      expect(result, isA<Left<Failure, NavigationRoute>>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, 'Server error');
    });

    test('should return ConnectionFailure when ConnectionException is thrown', () async {
      final routeInput = createRouteInput();
      when(() => mockProvider.computeRoute(routeInput))
          .thenThrow(ConnectionException());

      final result = await repository.fetchNavigationRoute(routeInput);

      expect(result, isA<Left<Failure, NavigationRoute>>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ConnectionFailure>());
    });

    test('should return UnknownFailure when other exception is thrown', () async {
      final routeInput = createRouteInput();
      when(() => mockProvider.computeRoute(routeInput))
          .thenThrow(Exception('Unknown error'));

      final result = await repository.fetchNavigationRoute(routeInput);

      expect(result, isA<Left<Failure, NavigationRoute>>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<UnknownFailure>());
    });

    test('should handle different route inputs', () async {
      final routeInput1 = RouteInput(
        origin: LatLng(40.4168, -3.7038),
        destination: LatLng(41.3851, 2.1734),
        mode: TravelModeEnum.DRIVE,
        routingPreference: RoutingPreferenceEnum.TRAFFIC_AWARE,
        languageCode: 'en',
      );
      final mockRoute = createMockRoute();
      when(() => mockProvider.computeRoute(routeInput1))
          .thenAnswer((_) async => mockRoute);

      final result = await repository.fetchNavigationRoute(routeInput1);

      expect(result, isA<Right<Failure, NavigationRoute>>());
      verify(() => mockProvider.computeRoute(routeInput1)).called(1);
    });
  });
}

