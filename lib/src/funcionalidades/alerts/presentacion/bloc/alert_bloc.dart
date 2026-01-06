import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/alerts/datos/repositories/alert_repository.dart';
import 'package:nextmove_app/src/funcionalidades/alerts/dominio/alert_entity.dart';

part 'alert_event.dart';
part 'alert_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final AlertRepository alertRepository;

  AlertBloc() : alertRepository = AlertRepository(), super(AlertInitial()) {
    on<LoadAlertsEvent>(_onLoadAlertsEvent);
    on<CreateAlertEvent>(_onCreateAlertEvent);
    on<UpdateAlertEvent>(_onUpdateAlertEvent);
    on<DeleteAlertEvent>(_onDeleteAlertEvent);
    on<ToggleAlertEvent>(_onToggleAlertEvent);
  }

  Future<void> _onLoadAlertsEvent(
    LoadAlertsEvent event,
    Emitter<AlertState> emit,
  ) async {
    emit(AlertLoading());
    final result = await alertRepository.getStationAlerts();
    result.fold(
      (failure) {
        emit(AlertError(_mapFailureToMessage(failure)));
      },
      (alerts) {
        emit(AlertLoaded(alerts));
      },
    );
  }

  Future<void> _onCreateAlertEvent(
    CreateAlertEvent event,
    Emitter<AlertState> emit,
  ) async {
    if (state is AlertLoaded) {
      final currentState = state as AlertLoaded;
      emit(AlertLoading());
      final result = await alertRepository.createStationAlert(
        stationId: event.stationId,
        horas: event.horas,
        diasSemana: event.diasSemana,
      );
      result.fold(
        (failure) {
          emit(AlertError(_mapFailureToMessage(failure)));
          emit(currentState);
        },
        (alert) {
          final updatedAlerts = [...currentState.alerts, alert];
          emit(AlertLoaded(updatedAlerts));
        },
      );
    }
  }

  Future<void> _onUpdateAlertEvent(
    UpdateAlertEvent event,
    Emitter<AlertState> emit,
  ) async {
    if (state is AlertLoaded) {
      final currentState = state as AlertLoaded;
      emit(AlertLoading());
      final result = await alertRepository.updateStationAlert(
        id: event.id,
        horas: event.horas,
        diasSemana: event.diasSemana,
        activa: event.activa,
      );
      result.fold(
        (failure) {
          emit(AlertError(_mapFailureToMessage(failure)));
          emit(currentState);
        },
        (updatedAlert) {
          final updatedAlerts = currentState.alerts.map((alert) {
            return alert.id == updatedAlert.id ? updatedAlert : alert;
          }).toList();
          emit(AlertLoaded(updatedAlerts));
        },
      );
    }
  }

  Future<void> _onDeleteAlertEvent(
    DeleteAlertEvent event,
    Emitter<AlertState> emit,
  ) async {
    if (state is AlertLoaded) {
      final currentState = state as AlertLoaded;
      emit(AlertLoading());
      final result = await alertRepository.deleteStationAlert(event.id);
      result.fold(
        (failure) {
          emit(AlertError(_mapFailureToMessage(failure)));
          emit(currentState);
        },
        (success) {
          if (success) {
            final updatedAlerts = currentState.alerts
                .where((alert) => alert.id != event.id)
                .toList();
            emit(AlertLoaded(updatedAlerts));
          } else {
            emit(AlertError('No se pudo eliminar la alerta'));
            emit(currentState);
          }
        },
      );
    }
  }

  Future<void> _onToggleAlertEvent(
    ToggleAlertEvent event,
    Emitter<AlertState> emit,
  ) async {
    if (state is AlertLoaded) {
      final currentState = state as AlertLoaded;
      final result = await alertRepository.toggleStationAlert(
        event.id,
        event.activa,
      );
      result.fold(
        (failure) {
          emit(AlertError(_mapFailureToMessage(failure)));
        },
        (updatedAlert) {
          final updatedAlerts = currentState.alerts.map((alert) {
            return alert.id == updatedAlert.id ? updatedAlert : alert;
          }).toList();
          emit(AlertLoaded(updatedAlerts));
        },
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure.message != null && failure.message!.isNotEmpty) {
      return failure.message!;
    }
    if (failure is ConnectionFailure) {
      return 'Error de conexión';
    }
    if (failure is ServerFailure) {
      return 'Error del servidor';
    }
    if (failure is AuthFailure) {
      return 'Error de autenticación';
    }
    return 'Error desconocido';
  }
}

