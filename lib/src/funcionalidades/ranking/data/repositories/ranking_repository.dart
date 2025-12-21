import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/ranking/data/dataproviders/ranking_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/ranking/domain/ranking_entry.dart';

class RankingRepository {
  final RankingRemoteDataProvider rankingRemoteDataProvider;
  RankingRepository() : rankingRemoteDataProvider = RankingRemoteDataProvider();

  Future<Either<Failure, List<RankingEntry>?>> getRankingData(
    String metric,
  ) async {
    try {
      final rankingData = await rankingRemoteDataProvider.getRanking(metric);
      // final rankingEntries = rankingData?.map((entry) => RankingEntry.fromJson(entry)).toList();
      final rankingEntries = rankingData?.map((entry) => RankingEntry(email: entry)).toList();
      return Right(rankingEntries);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in getRankingData: $e');
      }
      throw UnknownFailure();
    }
  }
}
