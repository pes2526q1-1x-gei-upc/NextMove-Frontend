import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/data/dataproviders/challenges_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';

class ChallengesRepository {
  final ChallengesRemoteDataProvider challengesRemoteDataProvider;
  ChallengesRepository([ChallengesRemoteDataProvider? dataProvider])
    : challengesRemoteDataProvider =
          dataProvider ?? ChallengesRemoteDataProvider();

  Future<Either<Failure, List<Challenge>?>> getallChallenges() async {
    try {
      final challengesData = await challengesRemoteDataProvider
          .getAllChallenges();
      final enrolledChallengesNames =
          await challengesRemoteDataProvider.getEnrolledChallengesNames() ?? [];
      final List<Challenge>? challengeEntries = challengesData
          ?.map((entry) => Challenge.fromJson(entry, enrolledChallengesNames))
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
