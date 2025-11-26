import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/data/dataProviders/recorded_route_data_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';


class RecordedRoutesRepository {
  final RecordedRouteDataProvider recordedRouteDataProvider;
  RecordedRoutesRepository() : recordedRouteDataProvider = RecordedRouteDataProvider();

  Future<Either<Failure, List<RecordedRoute>>> getRecordedRoutesByUser(String userEmail) async {
    try {
      final routes =
          await recordedRouteDataProvider.getRecordedRoutes(userEmail);
      return Right(routes);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in getRecordedRoutes: $e');
      }
      throw UnknownFailure();
    }
  }
}