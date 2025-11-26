import 'dart:async'; // Necesario para TimeoutException
import 'dart:io';    // Necesario para SocketException
import 'package:dartz/dartz.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/data/dataproviders/assessments_remote_data_provider.dart';

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
      return Left(ConnectionFailure(message: "No hay conexión a internet"));
      
    } on TimeoutException {
      return Left(ConnectionFailure(message: "El servidor tardó demasiado en responder"));
      
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
      
    } catch (e) {
      return Left(ServerFailure(message: "Ocurrió un error inesperado: ${e.toString()}"));
    }
  }
}