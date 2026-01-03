import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/data/dataproviders/challenges_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/enrolled_challenge.dart';

class ChallengesRepository {
  final ChallengesRemoteDataProvider challengesRemoteDataProvider;
  ChallengesRepository([ChallengesRemoteDataProvider? dataProvider])
    : challengesRemoteDataProvider =
          dataProvider ?? ChallengesRemoteDataProvider();

  Future<Either<Failure, List<Challenge>?>> getallChallenges() async {
    try {
      final challengesData = await challengesRemoteDataProvider
          .getAllChallenges();
      final List<Challenge>? challengeEntries = challengesData
          ?.map((entry) => Challenge.fromJson(entry))
          .toList();
      return Right(challengeEntries);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in getChallengesData: $e');
      }
      throw UnknownFailure();
    }
  }

  Future<Either<Failure, EnrolledChallenge?>> getEnrolledChallenge() async {
    try {
      final enrolledChallengeData = await challengesRemoteDataProvider
          .getEnrolledChallenge();
      if (enrolledChallengeData == null || enrolledChallengeData.isEmpty) {
        return const Right(null);
      }
      final EnrolledChallenge enrolledChallengeEntry =
          EnrolledChallenge.fromJson(enrolledChallengeData.first);
      return Right(enrolledChallengeEntry);
    } on ServerException catch (e) {
      if (kDebugMode) {
        print('ServerException in getEnrolledChallenge: ${e.message}');
      }
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in getEnrolledChallenges: $e');
      }
      throw UnknownFailure();
    }
  }

  Future<Either<Failure, void>> enrollInChallenge(String challengeId) async {
    try {
      await challengesRemoteDataProvider.enrollInChallenge(challengeId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in enrollInChallenge: $e');
      }
      throw UnknownFailure();
    }
  }
}
