import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/alerts/datos/dataproviders/alert_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/alerts/dominio/alert_entity.dart';

class AlertRepository {
  final AlertRemoteDataProvider alertRemoteDataProvider;
  
  AlertRepository({AlertRemoteDataProvider? alertRemoteDataProvider})
      : alertRemoteDataProvider = alertRemoteDataProvider ?? AlertRemoteDataProvider();

  Future<Either<Failure, List<StationAlert>>> getStationAlerts() async {
    try {
      final alerts = await alertRemoteDataProvider.getStationAlerts();
      return Right(alerts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in getStationAlerts: $e');
      }
      return Left(UnknownFailure());
    }
  }

  Future<Either<Failure, StationAlert?>> getStationAlert(String id) async {
    try {
      final alert = await alertRemoteDataProvider.getStationAlert(id);
      return Right(alert);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in getStationAlert: $e');
      }
      return Left(UnknownFailure());
    }
  }

  Future<Either<Failure, StationAlert>> createStationAlert({
    required String stationId,
    required List<String> horas,
    required List<int> diasSemana,
  }) async {
    try {
      final alert = await alertRemoteDataProvider.createStationAlert(
        stationId: stationId,
        horas: horas,
        diasSemana: diasSemana,
      );
      return Right(alert);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in createStationAlert: $e');
      }
      return Left(UnknownFailure());
    }
  }

  Future<Either<Failure, StationAlert>> updateStationAlert({
    required String id,
    required List<String> horas,
    required List<int> diasSemana,
    bool? activa,
  }) async {
    try {
      final alert = await alertRemoteDataProvider.updateStationAlert(
        id: id,
        horas: horas,
        diasSemana: diasSemana,
        activa: activa,
      );
      return Right(alert);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in updateStationAlert: $e');
      }
      return Left(UnknownFailure());
    }
  }

  Future<Either<Failure, bool>> deleteStationAlert(String id) async {
    try {
      final result = await alertRemoteDataProvider.deleteStationAlert(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in deleteStationAlert: $e');
      }
      return Left(UnknownFailure());
    }
  }

  Future<Either<Failure, StationAlert>> toggleStationAlert(String id, bool activa) async {
    try {
      final alert = await alertRemoteDataProvider.toggleStationAlert(id, activa);
      return Right(alert);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in toggleStationAlert: $e');
      }
      return Left(UnknownFailure());
    }
  }
}

