import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/data/dataProviders/recorded_route_data_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';


class RecordedTracksRepository {
  final RecordedTrackDataProvider recordedTrackDataProvider;
  RecordedTracksRepository() : recordedTrackDataProvider = RecordedTrackDataProvider();

  Future<Either<Failure, List<RecordedTrack>>> getRecordedTracksByUser(String userEmail) async {
    try {
      final routes =
          await recordedTrackDataProvider.getRecordedTracks(userEmail);
      return Right(routes);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in getRecordedTracks: $e');
      }
      throw UnknownFailure();
    }
  }
}