part of 'station_list_bloc.dart';

@immutable
sealed class StationListEvent {}

class LoadStationListEvent extends StationListEvent {}

class SearchStationListEvent extends StationListEvent {
  final String query;

  SearchStationListEvent({required this.query});
}