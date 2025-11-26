import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_entity.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/data/dataproviders/assessments_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_info_entity.dart';

class AssessmentRepository {
  final AssessmentRemoteDataProvider remoteDataProvider;

  AssessmentRepository({AssessmentRemoteDataProvider? remoteDataProvider}) 
      : remoteDataProvider = remoteDataProvider ?? AssessmentRemoteDataProvider();

  Future<Either<Failure, void>> createAssessment({
    required String stationId,
    required int score,
    required String comment,
  }) async {
    try {
      await remoteDataProvider.createAssessment(stationId, score, comment);
      return const Right(null);
    } on SocketException {
      return const Left(ConnectionFailure(message: "No hay conexión a internet"));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<AssessmentEntity>>> getAssessmentsByStation(String stationId) async {
    try {
      final assessments = await remoteDataProvider.getAssessmentsByStation(stationId);
      return Right(assessments);
    } on SocketException {
      return const Left(ConnectionFailure(message: "No hay conexión a internet"));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

Future<Either<Failure, AssessmentInfoEntity>> getStationAssessmentInfo(String stationId) async {
    try {
      final info = await remoteDataProvider.getStationAssessmentInfo(stationId);
      return Right(info);
    } on SocketException {
      return const Left(ConnectionFailure(message: "No hay conexión a internet"));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}