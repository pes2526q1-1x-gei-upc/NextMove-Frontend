import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/repositories/station_repository.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

part 'station_list_event.dart';
part 'station_list_state.dart';

class StationListBloc extends Bloc<StationListEvent, StationListState> {
  final StationRepository stationRepository;
  StationListBloc()
    : stationRepository = StationRepository(),
      super(StationListInitial()) {
    on<LoadStationListEvent>(_onLoadStationListEvent);
    on<SearchStationListEvent>(_onSearchStationListEvent);
  }

  Future<void> _onLoadStationListEvent(
    LoadStationListEvent event,
    Emitter<StationListState> emit,
  ) async {
    final prevState = state;
    emit(StationListLoading());
    final result = event.stationType == StationType.bicycle
        ? await stationRepository.getAllNearbyBicycleStationDetails(event.latitude, event.longitude)
        : await stationRepository.getAllNearbyEVStationDetails(event.latitude, event.longitude);
    result.fold(
      (failure) {
        emit(StationListError(_mapFailureToMessage(failure)));
        emit(prevState);
      },
      (stations) => emit(StationListLoaded(stations ?? [])),
    );
  }

  Future<void> _onSearchStationListEvent(
    SearchStationListEvent event,
    Emitter<StationListState> emit,
  ) async {}

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
