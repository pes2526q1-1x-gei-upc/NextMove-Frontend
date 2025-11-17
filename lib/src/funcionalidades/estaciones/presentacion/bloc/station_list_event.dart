part of 'station_list_bloc.dart';

@immutable
sealed class StationListEvent {}

class LoadStationListEvent extends StationListEvent {
  final StationType stationType;

  LoadStationListEvent({required this.stationType});
}

class SearchStationListEvent extends StationListEvent {
  final String query;

  SearchStationListEvent({required this.query});
}