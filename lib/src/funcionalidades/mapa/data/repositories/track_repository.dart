import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/dataproviders/track_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';
import 'package:nextmove_app/main.dart'; // for userProvider
import 'package:graphql_flutter/graphql_flutter.dart';

class TrackRepository {
  final TrackDataProvider trackDataProvider;
  TrackRepository(GraphQLClient client) : trackDataProvider = TrackDataProvider(client);
  
  Future<Either<Failure, void>> saveRecordedTrack(RecordedTrack track) async {
    try {
      await trackDataProvider.saveRecordedTrack(track, userProvider.email!);
      return Right(null);
    } on custom_exceptions.ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      if (kDebugMode) {
        print('UnknownFailure in saveRecordedTrack: $e');
      }
      return Left(UnknownFailure());
    }
  }
}
