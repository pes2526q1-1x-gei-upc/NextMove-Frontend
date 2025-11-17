import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/repositories/station_repository.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

part 'station_details_event.dart';
part 'station_details_state.dart';

class StationDetailsBloc
    extends Bloc<StationDetailsEvent, StationDetailsState> {
  final StationRepository stationRepository;

  StationDetailsBloc()
    : stationRepository = StationRepository(),
      super(StationDetailsInitial()) {
    on<LoadStationDetailsEvent>(_onLoadStationDetailsEvent);
    on<ToggleFavoriteStatusEvent>(_onToggleFavoriteStatusEvent);
  }

  Future<void> _onLoadStationDetailsEvent(
    LoadStationDetailsEvent event,
    Emitter<StationDetailsState> emit,
  ) async {
    if (event.stationDetails != null) {
      emit(StationDetailsLoaded(event.stationDetails!));
      return;
    }
    final prevState = state;
    emit(StationDetailsLoading());
    final result = event.stationType == StationType.bicycle
        ? await stationRepository.getBicycleStationDetails(event.stationId)
        : await stationRepository.getEVStationDetails(event.stationId);

    result.fold((failure) {
      emit(StationDetailsError(_mapFailureToMessage(failure)));
      emit(prevState);
    }, (station) => emit(StationDetailsLoaded(station)));
  }

  Future<void> _onToggleFavoriteStatusEvent(
    ToggleFavoriteStatusEvent event,
    Emitter<StationDetailsState> emit,
  ) async {
    throw UnimplementedError();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure.message != null && failure.message!.isNotEmpty) {
      return failure.message!;
    }
    if (failure is ConnectionFailure) {
      return 'connection-error';
    }
    if (failure is ServerFailure) {
      return 'server-error';
    }
    if (failure is AuthFailure) {
      return 'auth-error';
    }
    return 'unknown-error';
  }
}
