import 'package:dartz/dartz.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/repositories/station_remote_data_provider.dart';

class StationRepository {
  final StationRemoteDataProvider stationRemoteDataProvider;
  StationRepository() : stationRemoteDataProvider = StationRemoteDataProvider();

  Future<Either<Failure, bool>> isEmailRegistered(String email) async {
    try {
      return Right(await stationRemoteDataProvider.isEmailRegistered(email));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(UnknownFailure());
    }
  }
