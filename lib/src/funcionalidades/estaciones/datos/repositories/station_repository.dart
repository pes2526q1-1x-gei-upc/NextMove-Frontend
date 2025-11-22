import 'package:dartz/dartz.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/dataproviders/station_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

class StationRepository {
  final StationRemoteDataProvider stationRemoteDataProvider;
  StationRepository() : stationRemoteDataProvider = StationRemoteDataProvider();

  Future<Either<Failure, List<BicycleStationDetails>?>>
  getAllNearbyBicycleStationDetails(double latitude, double longitude) async {
    try {
      return Right(
        await stationRemoteDataProvider.getAllNearbyBicycleStationDetails(
          latitude,
          longitude,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      throw UnknownFailure();
    }
  }

  Future<Either<Failure, List<EVStationDetails>?>> getAllNearbyEVStationDetails(
    double latitude,
    double longitude,
  ) async {
    try {
      return Right(
        await stationRemoteDataProvider.getAllNearbyEVStationDetails(
          latitude,
          longitude,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      throw UnknownFailure();
    }
  }

  Future<Either<Failure, List<BicycleStationDetails>?>>
  getAllBicycleStationDetails() async {
    try {
      return Right(
        await stationRemoteDataProvider.getAllBicycleStationDetails(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      throw UnknownFailure();
    }
  }

  Future<Either<Failure, List<EVStationDetails>?>>
  getAllEVStationDetails() async {
    try {
      return Right(await stationRemoteDataProvider.getAllEVStationDetails());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      throw UnknownFailure();
    }
  }

  Future<Either<Failure, BicycleStationDetails>> getBicycleStationDetails(
    String stationID,
  ) async {
    try {
      return Right(
        await stationRemoteDataProvider.getBicycleStationDetails(stationID),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      throw UnknownFailure();
    }
  }

  Future<Either<Failure, EVStationDetails>> getEVStationDetails(
    String stationID,
  ) async {
    try {
      return Right(
        await stationRemoteDataProvider.getEVStationDetails(stationID),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      throw UnknownFailure();
    }
  }
}
