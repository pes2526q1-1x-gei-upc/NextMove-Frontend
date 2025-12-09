import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/data/dataProviders/track_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recording_track.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_track.dart';

class TrackRepository {
  final TrackDataProvider trackDataProvider;
  TrackRepository() : trackDataProvider = TrackDataProvider();

  Future<Either<Failure, void>> saveRecordingTrack(RecordingTrack track) async {
    try {
      await trackDataProvider.saveRecordingTrack(track);
      return Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in saveRecordingTrack: $e');
      }
      return Left(UnknownFailure());
    }
  }

  Future<Either<Failure, List<RecordedTrack>>> getRecordedTracksByUser(
    String userEmail,
  ) async {
    try {
      final routes = await trackDataProvider.getRecordedTracksByUser(userEmail);
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
