import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/dataproviders/navigation_route_provider.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/navigation_route.dart';
import 'package:nextmove_app/src/shared/domain/route_input.dart';

class NavigationRouteRepository {
  final NavigationRouteDataProvider navigationRouteProvider;

  NavigationRouteRepository({NavigationRouteDataProvider? navigationRouteProvider})
      : navigationRouteProvider = navigationRouteProvider ?? NavigationRouteDataProvider();

  Future<Either<Failure, NavigationRoute>> fetchNavigationRoute(
      RouteInput routeInput) async {
    try {
      final route = await navigationRouteProvider.computeRoute(
          routeInput);
      return Right(route);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in fetchNavigationRoute: $e');
      }
      return Left(UnknownFailure());
    }
  }
}
