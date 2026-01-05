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
      // Una lista vacía es válida, no es un error
      return Right(routes);
    } on ServerException catch (e) {
      // Verificar si el error es porque no hay recorridos (lista vacía es válida)
      // Si el backend devuelve una excepción por no haber recorridos, tratamos como lista vacía
      final message = e.message?.toLowerCase() ?? '';
      if (message.contains('no hay') || 
          message.contains('no encontrado') ||
          message.contains('not found') ||
          message.contains('empty')) {
        return Right([]);
      }
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in getRecordedRoutes: $e');
      }
      // Devolver Left en lugar de lanzar excepción
      return Left(UnknownFailure(message: 'Error desconocido al obtener recorridos'));
    }
  }
}