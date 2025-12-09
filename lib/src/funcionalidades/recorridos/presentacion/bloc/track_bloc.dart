import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/data/repositories/track_repository.dart';
import 'track_events.dart';
import 'track_state.dart';

class TrackBloc extends Bloc<TrackEvent, TrackState> {
  final TrackRepository trackRepository;

  TrackBloc() : trackRepository = TrackRepository(),
      super(const TrackInitialState()) {
    on<LoadRecordedTracksEvent>(_onLoadRecordedTracks);
  }

  Future<void> _onLoadRecordedTracks(
      LoadRecordedTracksEvent event, 
      Emitter<TrackState> emit
    ) async {
        emit(const TrackLoadingState());
        final result =
            await trackRepository.getRecordedTracksByUser(event.userEmail);

        result.fold(
          (failure) {
            emit(TrackErrorState(failure.message));
          },
          (recordedTracks) {
            emit(TrackLoadedState(recordedTracks: recordedTracks));
          },
        );
    }
}