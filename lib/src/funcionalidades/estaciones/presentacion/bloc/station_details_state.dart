part of 'station_details_bloc.dart';

@immutable
sealed class StationDetailsState {}

final class StationDetailsInitial extends StationDetailsState {}

final class StationDetailsLoading extends StationDetailsState {}

final class StationDetailsLoaded extends StationDetailsState {
  final StationDetails stationDetails;

  StationDetailsLoaded(this.stationDetails);
}

final class StationDetailsError extends StationDetailsState {
  final String message;

  StationDetailsError(this.message);
}