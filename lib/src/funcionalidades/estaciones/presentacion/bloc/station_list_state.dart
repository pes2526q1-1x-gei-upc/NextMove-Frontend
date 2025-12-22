part of 'station_list_bloc.dart';

@immutable
sealed class StationListState {}

final class StationListInitial extends StationListState {}

final class StationListLoading extends StationListState {}

final class StationListLoaded extends StationListState {
  final List<StationDetails> stations;

  StationListLoaded(this.stations);
}

final class StationListError extends StationListState {
  final String message;

  StationListError(this.message);
}

final class StationListToggleError extends StationListState {
  final String message;
  final List<StationDetails> stations;

  StationListToggleError(this.message, this.stations);
}