import 'package:equatable/equatable.dart';

abstract class TrackEvent extends Equatable {
  const TrackEvent();

  @override
  List<Object?> get props => [];

}

class LoadRecordedTracksEvent extends TrackEvent {
  final String userEmail;
  const LoadRecordedTracksEvent(this.userEmail);

  @override
  List<Object?> get props => [userEmail];
}