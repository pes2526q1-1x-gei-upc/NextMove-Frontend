import 'package:equatable/equatable.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';

abstract class TrackState extends Equatable {
  const TrackState();

  @override
  List<Object?> get props => [];
}

class TrackInitialState extends TrackState {
  const TrackInitialState();
}

class TrackLoadingState extends TrackState {
  const TrackLoadingState();
}

class TrackLoadedState extends TrackState {
  final List<RecordedTrack> recordedTracks;

  const TrackLoadedState({this.recordedTracks = const []});

  @override
  List<Object?> get props => [recordedTracks];

  TrackLoadedState copyWith({
    List<RecordedTrack>? recordedTracks,
  }) {
    return TrackLoadedState(
      recordedTracks: recordedTracks ?? this.recordedTracks,
    );
  }
}

class TrackErrorState extends TrackState {
  final String? message;

  const TrackErrorState(this.message);

  @override
  List<Object?> get props => [message];
}