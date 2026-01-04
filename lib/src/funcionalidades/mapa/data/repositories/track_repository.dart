import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/dataproviders/track_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/track_validator.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class TrackRepository {
  final TrackDataProvider trackDataProvider;
  TrackRepository() : trackDataProvider = TrackDataProvider();
  
  Future<Either<Failure, void>> saveRecordedTrack(RecordedTrack track, AppLocalizations l10n, {bool bikePhoto = false}) async {
    try {
      final validator = TrackValidator(l10n);
      final validationResult = validator.validate(track);
      
      if (!validationResult.isValid) {
        // Retornar error de validación
        return Left(ValidationFailure(message: validationResult.reason!));
      }

      await trackDataProvider.saveRecordedTrack(track, bikePhoto: bikePhoto);
      return Right(null);
    } on ServerException catch (e) {
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
