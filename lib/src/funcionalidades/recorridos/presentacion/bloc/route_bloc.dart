import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/data/repositories/recorded_routes_repository.dart';
import 'route_events.dart';
import 'route_state.dart';

class TrackBloc extends Bloc<TrackEvent, TrackState> {
  final RecordedTracksRepository recordedTracksRepository;

  TrackBloc() : recordedTracksRepository = RecordedTracksRepository(),
      super(const TrackInitialState()) {
    on<LoadRecordedTracksEvent>(_onLoadRecordedTracks);
  }

  Future<void> _onLoadRecordedTracks(
      LoadRecordedTracksEvent event, 
      Emitter<TrackState> emit
    ) async {
        emit(const TrackLoadingState());
        final result =
            await recordedTracksRepository.getRecordedTracksByUser(event.userEmail);

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