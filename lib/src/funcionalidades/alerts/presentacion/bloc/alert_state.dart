part of 'alert_bloc.dart';

@immutable
sealed class AlertState {}

final class AlertInitial extends AlertState {}

final class AlertLoading extends AlertState {}

final class AlertLoaded extends AlertState {
  final List<StationAlert> alerts;

  AlertLoaded(this.alerts);
}

final class AlertError extends AlertState {
  final String message;

  AlertError(this.message);
}

