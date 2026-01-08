part of 'alert_bloc.dart';

@immutable
sealed class AlertEvent {}

class LoadAlertsEvent extends AlertEvent {}

class CreateAlertEvent extends AlertEvent {
  final String stationId;
  final List<String> horas;
  final List<int> diasSemana;

  CreateAlertEvent({
    required this.stationId,
    required this.horas,
    required this.diasSemana,
  });
}

class UpdateAlertEvent extends AlertEvent {
  final String id;
  final List<String> horas;
  final List<int> diasSemana;
  final bool? activa;

  UpdateAlertEvent({
    required this.id,
    required this.horas,
    required this.diasSemana,
    this.activa,
  });
}

class DeleteAlertEvent extends AlertEvent {
  final String id;

  DeleteAlertEvent({required this.id});
}

class ToggleAlertEvent extends AlertEvent {
  final String id;
  final bool activa;

  ToggleAlertEvent({required this.id, required this.activa});
}

