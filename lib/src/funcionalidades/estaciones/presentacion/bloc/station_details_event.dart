part of 'station_details_bloc.dart';

@immutable
sealed class StationDetailsEvent {}

class LoadStationDetailsEvent extends StationDetailsEvent {
  final String stationId;
  final StationType stationType;
  LoadStationDetailsEvent(this.stationId, this.stationType);
}

class ToggleFavoriteStatusEvent extends StationDetailsEvent {
  final String stationId;

  ToggleFavoriteStatusEvent(this.stationId);
}