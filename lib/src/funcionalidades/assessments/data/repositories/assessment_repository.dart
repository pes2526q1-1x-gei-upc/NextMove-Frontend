import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_entity.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/data/dataproviders/assessments_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_info_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/data/repositories/user_repository.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';

class AssessmentRepository {
  final AssessmentRemoteDataProvider remoteDataProvider;
  final UserRepository userRepository;

  AssessmentRepository({
    AssessmentRemoteDataProvider? remoteDataProvider,
    UserRepository? userRepository,
  }) : remoteDataProvider =
           remoteDataProvider ?? AssessmentRemoteDataProvider(),
       userRepository = userRepository ?? UserRepository();

  Future<Either<Failure, void>> createAssessment({
    required String stationId,
    required int score,
    required String comment,
  }) async {
    try {
      await remoteDataProvider.createAssessment(stationId, score, comment);
      return const Right(null);
    } on SocketException {
      return const Left(
        ConnectionFailure(message: "No hay conexión a internet"),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<AssessmentEntity>>> getAssessmentsByStation(
    String stationId,
  ) async {
    try {
      final assessments = await remoteDataProvider.getAssessmentsByStation(
        stationId,
      );
      return Right(assessments);
    } on SocketException {
      return const Left(
        ConnectionFailure(message: "No hay conexión a internet"),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, AssessmentInfoEntity>> getStationAssessmentInfo(
    String stationId,
  ) async {
    try {
      final info = await remoteDataProvider.getStationAssessmentInfo(stationId);
      return Right(info);
    } on SocketException {
      return const Left(
        ConnectionFailure(message: "No hay conexión a internet"),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> updateAssessment({
    required String stationId,
    required int score,
    required String comment,
  }) async {
    try {
      await remoteDataProvider.updateAssessment(stationId, score, comment);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteAssessment(String stationId) async {
    try {
      await remoteDataProvider.deleteAssessment(stationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<UserEntity?> getUserEmailByNickname(String nickname) async {
    final result = await userRepository.getUserProfile(nickname);

    return result.fold(
      (failure) {
        return null;
      },
      (userEntity) {
        return userEntity;
      },
    );
  }

  Future<Either<Failure, bool>> checkAssessed(String stationId) async {
    try {
      final hasAssessed = await remoteDataProvider.checkAssessed(stationId);
      return Right(hasAssessed);
    } on SocketException {
      return const Left(
        ConnectionFailure(message: "No hay conexión a internet"),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
