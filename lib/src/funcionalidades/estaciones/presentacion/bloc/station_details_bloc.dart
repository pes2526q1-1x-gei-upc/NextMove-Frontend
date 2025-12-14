import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/repositories/station_repository.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/stations_cache.dart';

part 'station_details_event.dart';
part 'station_details_state.dart';

class StationDetailsBloc
    extends Bloc<StationDetailsEvent, StationDetailsState> {
  final StationRepository stationRepository;
  final StationsCache stationsCache;

  StationDetailsBloc(this.stationsCache)
    : stationRepository = StationRepository(),
      super(StationDetailsInitial()) {
    on<LoadStationDetailsEvent>(_onLoadStationDetailsEvent);
    on<ToggleFavoriteEvent>(_onToggleFavoriteEvent);
  }

  Future<void> _onLoadStationDetailsEvent(
    LoadStationDetailsEvent event,
    Emitter<StationDetailsState> emit,
  ) async {
    if (event.stationDetails != null) {
      emit(StationDetailsLoaded(event.stationDetails!));
      stationsCache.updateStation(event.stationDetails!);
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
    }, (station) {
      emit(StationDetailsLoaded(station));
      stationsCache.updateStation(station);
    });
  }

  Future<void> _onToggleFavoriteEvent(
    ToggleFavoriteEvent event,
    Emitter<StationDetailsState> emit,
  ) async {
    if (state is StationDetailsLoaded) {
      final currentState = state as StationDetailsLoaded;
      final isFavorite = currentState.stationDetails.isFavorite ?? false;
      stationRepository.setStationFavoriteStatus(
        currentState.stationDetails.id,
        currentState.stationDetails is BicycleStationDetails
            ? StationType.bicycle
            : StationType.electricVehicle,
        !isFavorite,
      );
      currentState.stationDetails.isFavorite = !isFavorite;
      emit(StationDetailsLoaded(currentState.stationDetails));
      stationsCache.updateStation(currentState.stationDetails);
    }
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
