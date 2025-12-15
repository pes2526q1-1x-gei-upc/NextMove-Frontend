import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/repositories/station_repository.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/stations_cache.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

part 'station_list_event.dart';
part 'station_list_state.dart';

class StationListBloc extends Bloc<StationListEvent, StationListState> {
  final StationRepository stationRepository;
  final StationsCache stationsCache;

  StationListBloc(this.stationsCache)
    : stationRepository = StationRepository(),
      super(StationListInitial()) {
    on<LoadStationListEvent>(_onLoadStationListEvent);
    on<SearchStationListEvent>(_onSearchStationListEvent);
    on<ToggleFavoriteEvent>(_onToggleFavoriteEvent);
  }

  Future<void> _onLoadStationListEvent(
    LoadStationListEvent event,
    Emitter<StationListState> emit,
  ) async {
    final prevState = state;
    emit(StationListLoading());
    final result = event.stationType == StationType.bicycle
        ? await stationRepository.getAllNearbyBicycleStationDetails(
            event.latitude,
            event.longitude,
          )
        : await stationRepository.getAllNearbyEVStationDetails(
            event.latitude,
            event.longitude,
          );
    result.fold((failure) {
      emit(StationListError(_mapFailureToMessage(failure)));
      emit(prevState);
    }, (stations) {
      final loadedStations = stations ?? [];
      stationsCache.updateStations(loadedStations);
      emit(StationListLoaded(loadedStations));
    });
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

  Future<void> _onToggleFavoriteEvent(
    ToggleFavoriteEvent event,
    Emitter<StationListState> emit,
  ) async {
    if (state is StationListLoaded) {
      final currentState = state as StationListLoaded;
      final station = currentState.stations.firstWhere(
        (s) => s.id == event.stationId,
      );
      final oldIsFavorite = station.isFavorite ?? false;
      final newIsFavorite = !oldIsFavorite;
      final stationType = station is BicycleStationDetails
          ? StationType.bicycle
          : StationType.electricVehicle;

      final result = await stationRepository.setStationFavoriteStatus(
        station.id,
        stationType,
        newIsFavorite,
      );
      result.fold(
        (failure) {
          emit(
            StationListToggleError(
              _mapFailureToMessage(failure),
              currentState.stations,
            ),
          );
        },
        (success) {
          final updatedStation = currentState.stations
              .firstWhere((s) => s.id == event.stationId);
          updatedStation.isFavorite = newIsFavorite;
          stationsCache.updateStation(updatedStation);
          emit(StationListLoaded(currentState.stations));
        },
      );
    }
  }
}
