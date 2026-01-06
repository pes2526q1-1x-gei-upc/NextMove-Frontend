import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/dataproviders/station_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

class StationRepository {
  final StationRemoteDataProvider stationRemoteDataProvider;

  StationRepository({StationRemoteDataProvider? stationRemoteDataProvider})
      : stationRemoteDataProvider =
            stationRemoteDataProvider ?? StationRemoteDataProvider();

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
      if (kDebugMode) {
        print('UnknownFailure in getAllNearbyBicycleStationDetails: $e');
      }
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
      if (kDebugMode) {
        print('UnknownFailure in getAllNearbyEVStationDetails: $e');
      }
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
      if (kDebugMode) {
        print('UnknownFailure in getAllBicycleStationDetails: $e');
      }
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
      if (kDebugMode) {
        print('UnknownFailure in getAllEVStationDetails: $e');
      }
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
      if (kDebugMode) {
        print('UnknownFailure in getBicycleStationDetails: $e');
      }
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
      if (kDebugMode) {
        print('UnknownFailure in getEVStationDetails: $e');
      }
      throw UnknownFailure();
    }
  }

  Future<Either<Failure, List<EVStationDetails>>> searchEvStations(String query) async{
    try {
      return Right(
        await stationRemoteDataProvider.searchEvStations(query),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in searchEvStations: $e');
      }
      throw UnknownFailure();
    }
  }

  Future<Either<Failure, List<BicycleStationDetails>>> searchBicycleStations(String query) async{
    try {
      return Right(
        await stationRemoteDataProvider.searchBicycleStations(query),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in searchBicycleStations: $e');
      }
      throw UnknownFailure();
    }
  }

  Future<Either<Failure, void>> setStationFavoriteStatus(String stationId, StationType stationType, bool isFavorite) async {
    try {
      await stationRemoteDataProvider.setStationFavoriteStatus(stationId, stationType, isFavorite);
      return Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in setStationFavoriteStatus: $e');
      }
      throw UnknownFailure();
    }
  }
  Future<Either<Failure, List<String>>> getFavCarStationIds() async {
    try {
      final ids = await stationRemoteDataProvider.getFavCarStationIds();
      return Right(ids);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in getFavCarStationIds: $e');
      }
      throw UnknownFailure();
    }
  }

  Future<Either<Failure, List<String>>> getFavBikeStationIds() async {
    try {
      final ids = await stationRemoteDataProvider.getFavBikeStationIds();
      return Right(ids);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in getFavBikeStationIds: $e');
      }
      throw UnknownFailure();
    }
  }
}
