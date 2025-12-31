part of 'station_details_bloc.dart';

@immutable
sealed class StationDetailsEvent {}

class LoadStationDetailsEvent extends StationDetailsEvent {
  final String stationId;
  final StationType stationType;
  final StationDetails? stationDetails;
  LoadStationDetailsEvent(this.stationId, this.stationType, [this.stationDetails]);
}

class ToggleFavoriteEvent extends StationDetailsEvent {
  final String stationId;

  ToggleFavoriteEvent(this.stationId);
}