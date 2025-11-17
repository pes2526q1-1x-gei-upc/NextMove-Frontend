part of 'station_details_bloc.dart';

@immutable
sealed class StationDetailsEvent {}

class LoadStationDetails extends StationDetailsEvent {
  final String stationId;
  final StationType stationType;
  LoadStationDetails(this.stationId, this.stationType);
}

class ToggleFavoriteStatus extends StationDetailsEvent {
  final String stationId;

  ToggleFavoriteStatus(this.stationId);
}