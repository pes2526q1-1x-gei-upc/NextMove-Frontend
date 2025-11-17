part of 'station_list_bloc.dart';

@immutable
sealed class StationListEvent {}

class LoadStationListEvent extends StationListEvent {
  final StationType stationType;
  final double latitude;
  final double longitude;

  LoadStationListEvent({required this.stationType, required this.latitude, required this.longitude});
}

class SearchStationListEvent extends StationListEvent {
  final String query;

  SearchStationListEvent({required this.query});
}