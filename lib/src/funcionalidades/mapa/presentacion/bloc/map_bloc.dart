import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/repositories/station_repository.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/repositories/track_repository.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';
import 'map_events.dart';
import 'map_state.dart';

var defaultPolyline = Polyline(
  polylineId: const PolylineId('current_track'),
  color: Colors.red,
  width: 5,
);

class MapBloc extends Bloc<MapEvent, MapState> {
  final StationRepository stationRepository;
  final TrackRepository trackRepository;
  final Function(StationDetails, MapLoadedState) onMarkerTapped;

  // Stream de ubicación
  StreamSubscription<Position>? _positionStreamSubscription;

  // Posición central por defecto (Barcelona)
  static const LatLng _bcnCenter = LatLng(41.3851, 2.1734);

  MapBloc({
    required this.stationRepository,
    required this.trackRepository,
    required this.onMarkerTapped,
  }) : super(const MapInitialState()) {
    // Registro de handlers para cada evento
    on<LoadMapDataEvent>(_onLoadMapData);
    on<ChangeModeEvent>(_onChangeMode);
    on<ToggleMapTypeEvent>(_onToggleMapType);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
    on<UpdateUserLocationEvent>(_onUpdateUserLocation);
    on<SearchStationsEvent>(_onSearchStations);
    on<ClearSearchEvent>(_onClearSearch);
    on<StartRouteRecordingEvent>(_onStartRouteRecording);
    on<StopRouteRecordingEvent>(_onStopRouteRecording);
    on<AddRoutePointEvent>(_onAddRoutePoint);
    on<ClearRouteEvent>(_onClearRoute);
  }

  /// Handler: Cargar datos iniciales (estaciones y ubicación)
  Future<void> _onLoadMapData(
    LoadMapDataEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoadingState());

    try {
      // Cargar estaciones en paralelo
      final results = await Future.wait([
        stationRepository.getAllBicycleStationDetails(),
        stationRepository.getAllEVStationDetails(),
      ]);

      final bikeStations = results[0].fold(
        (failure) => throw Exception(
          'Error cargando estaciones de bicicletas: ${failure.message}',
        ),
        (stations) => stations as List<BicycleStationDetails>? ?? [],
      );
      final evStations = results[1].fold(
        (failure) => throw Exception(
          'Error cargando estaciones de coches: ${failure.message}',
        ),
        (stations) => stations as List<EVStationDetails>? ?? [],
      );

      // Construir marcadores iniciales para bicicletas
      final bikeMarkers = _buildMarkersForStations(
        bikeStations,
        null,
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );

      final carMarkers = _buildMarkersForStations(
        null,
        evStations,
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );

      // Emitir estado cargado
      emit(
        MapLoadedState(
          bikeStations: bikeStations,
          evStations: evStations,
          userLocation: null,
          currentMode: StationType.bicycle,
          currentMapType: MapType.normal,
          bikeMarkers: bikeMarkers,
          carMarkers: carMarkers,
          centerPosition: _bcnCenter,
          searchQuery: null,
          searchResults: [],
          isSearching: false,
          routePolyline: defaultPolyline,
        ),
      );

      // Iniciar solicitud de permisos de ubicación
      add(const RequestLocationPermissionEvent());
    } catch (e) {
      emit(MapErrorState('Error cargando estaciones: $e'));
    }
  }

  /// Handler: Cambiar modo (bicicleta/coche)
  void _onChangeMode(ChangeModeEvent event, Emitter<MapState> emit) {
    final currentState = state;
    if (currentState is MapLoadedState) {
      emit(currentState.copyWith(currentMode: event.newMode));
    }
  }

  /// Handler: Cambiar tipo de mapa (normal/satélite)
  void _onToggleMapType(ToggleMapTypeEvent event, Emitter<MapState> emit) {
    final currentState = state;
    if (currentState is MapLoadedState) {
      final newMapType = currentState.currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;

      emit(currentState.copyWith(currentMapType: newMapType));
    }
  }

  /// Handler: Actualizar ubicación del usuario
  void _onUpdateUserLocation(
    UpdateUserLocationEvent event,
    Emitter<MapState> emit,
  ) {
    final currentState = state;
    if (currentState is MapLoadedState) {
      final newLocation = LatLng(event.latitude, event.longitude);

      // Add point to route if recording
      if (currentState.isRecordingRoute) {
        if (kDebugMode) {
          print(
            'Location update received while recording: ${event.latitude}, ${event.longitude}',
          );
        }
        add(
          AddRoutePointEvent(
            TrackPoint(
              location: newLocation,
              altitude: event.altitude,
              timestamp: DateTime.now(),
            ),
          ),
        );
      }

      emit(currentState.copyWith(userLocation: newLocation));
    }
  }

  /// Handler: Solicitar permisos de ubicación
  Future<void> _onRequestLocationPermission(
    RequestLocationPermissionEvent event,
    Emitter<MapState> emit,
  ) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        emit(const MapLocationPermissionDeniedState(isPermanentlyDenied: true));
        return;
      }

      if (permission == LocationPermission.denied) {
        emit(
          const MapLocationPermissionDeniedState(isPermanentlyDenied: false),
        );
        return;
      }

      // Permisos concedidos, iniciar stream de ubicación
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _startLocationUpdates();
      }
    } catch (e) {
      // Si falla la solicitud de permisos, continuar sin ubicación
      return;
    }
  }

  /// Handler: Buscar estaciones según consulta
  Future<void> _onSearchStations(
    SearchStationsEvent event,
    Emitter<MapState> emit,
  ) async {
    final currentState = state;
    if (currentState is MapLoadedState) {
      emit(currentState.copyWith(isSearching: true, searchQuery: event.query));

      final query = event.query.trim();

      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            searchQuery: null,
            searchResults: [],
            isSearching: false,
          ),
        );
        return;
      } else if (query.length < 3) {
        // Si la consulta es muy corta, no buscar
        emit(
          currentState.copyWith(
            searchQuery: query,
            isSearching: true,
            searchResults: [],
          ),
        );
        return;
      }

      emit(currentState.copyWith(isSearching: true));

      try {
        final result = currentState.currentMode == StationType.electricVehicle
            ? await stationRepository.searchEvStations(query)
            : await stationRepository.searchEvStations(query);

        result.fold(
          (failure) {
            throw Exception(
              'Error buscando estaciones de coches: ${failure.message}',
            );
          },
          (stations) {
            emit(
              currentState.copyWith(
                searchResults: stations,
                isSearching: true,
                searchQuery: query,
              ),
            );
          },
        );
      } catch (e) {
        // Si hay un error, emitir estado sin resultados
        emit(currentState.copyWith(searchResults: [], isSearching: false));
        return;
      }
    }
  }

  /// Handler: Limpiar resultados de búsqueda
  void _onClearSearch(ClearSearchEvent event, Emitter<MapState> emit) {
    final currentState = state;
    if (currentState is MapLoadedState) {
      emit(
        currentState.copyWith(
          searchQuery: null,
          searchResults: [],
          isSearching: false,
        ),
      );
    }
  }

  /// Iniciar actualizaciones de ubicación
  void _startLocationUpdates() async {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Actualizar cada 1 metro
    );

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: settings).listen(
          (Position? pos) {
            if (pos != null && !isClosed) {
              add(
                UpdateUserLocationEvent(
                  latitude: pos.latitude,
                  longitude: pos.longitude,
                  altitude: pos.altitude,
                ),
              );
            }
          },
          onError: (error) {
            if (kDebugMode) {
              print('Error en stream de ubicación: $error');
            }
          },
          cancelOnError: false,
        );

    // Get the current position immediately
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      add(
        UpdateUserLocationEvent(
          latitude: currentPosition.latitude,
          longitude: currentPosition.longitude,
          altitude: currentPosition.altitude,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current position: $e');
      }
    }
  }

  /// Construir marcadores para una lista de estaciones
  Set<Marker> _buildMarkersForStations(
    List<BicycleStationDetails>? bikeStations,
    List<EVStationDetails>? evStations,
    BitmapDescriptor icon,
  ) {
    if (bikeStations == null && evStations != null) {
      return evStations
          .where(
            (station) => station.latitude != null && station.longitude != null,
          )
          .map((station) {
            return Marker(
              markerId: MarkerId(station.id),
              position: LatLng(station.latitude!, station.longitude!),
              icon: icon,
              onTap: () => onMarkerTapped(station, state as MapLoadedState),
            );
          })
          .toSet();
    } else if (evStations == null && bikeStations != null) {
      return bikeStations
          .where(
            (station) => station.latitude != null && station.longitude != null,
          )
          .map((station) {
            return Marker(
              markerId: MarkerId(station.id),
              position: LatLng(station.latitude!, station.longitude!),
              icon: icon,
              onTap: () => onMarkerTapped(station, state as MapLoadedState),
            );
          })
          .toSet();
    }

    return {};
  }

  /// Handler: Iniciar grabación de ruta
  void _onStartRouteRecording(
    StartRouteRecordingEvent event,
    Emitter<MapState> emit,
  ) {
    final currentState = state;
    if (currentState is MapLoadedState) {
      if (kDebugMode) {
        print('Started route recording');
      }

      emit(
        currentState.copyWith(
          isRecordingRoute: true,
          recordedTrack: RecordedTrack(),
          routePolyline: defaultPolyline,
        ),
      );

      if (kDebugMode) {
        print('Polyline reset for route recording start');
      }
    }
  }

  void _onStopRouteRecording(
    StopRouteRecordingEvent event,
    Emitter<MapState> emit,
  ) async {
    final currentState = state;
    if (currentState is MapLoadedState) {
      currentState.recordedTrack!.endTime = DateTime.now();
      if (kDebugMode) {
        print(
          'Stopped route recording. Total points recorded: ${currentState.recordedTrack?.points.length ?? 0}',
        );
        print("Route information: ${currentState.recordedTrack.toString()}");
      }

      if (currentState.recordedTrack!.points.length < 2) {
        if (kDebugMode) {
          print('Not enough points recorded to save the track.');
        }
        emit(
          currentState.copyWith(
            isRecordingRoute: false,
            routePolyline: defaultPolyline,
          ),
        );
        return;
      }

      final saveResult = await trackRepository.saveRecordedTrack(
        currentState.recordedTrack!,
      );
      saveResult.fold(
        (failure) {
          if (kDebugMode) {
            print('Error saving recorded track: ${failure.message}');
            emit(
              MapErrorState('Error saving recorded track: ${failure.message}'),
            );
          }
        },
        (_) {
          if (kDebugMode) {
            print('Recorded track saved successfully.');
            emit(
              currentState.copyWith(
                isRecordingRoute: false,
                routePolyline: defaultPolyline,
              ),
            );
          }
        },
      );
    }
  }

  void _onAddRoutePoint(AddRoutePointEvent event, Emitter<MapState> emit) {
    final currentState = state;
    if (currentState is MapLoadedState && currentState.isRecordingRoute) {
      if (kDebugMode) {
        print(
          'Adding route point: ${event.point.location.latitude}, ${event.point.location.longitude} at ${event.point.timestamp}',
        );
        print(
          'Total points in track: ${(currentState.recordedTrack?.points.length ?? 0) + 1}',
        );
      }

      // add the new point to the recorded track
      currentState.recordedTrack!.addPoint(
        TrackPoint(
          location: event.point.location,
          altitude: event.point.altitude,
          timestamp: DateTime.now(),
        ),
      );

      // add the new point to the polyline
      final routePolyline = currentState.routePolyline.copyWith(
        pointsParam: [
          ...currentState.routePolyline.points,
          event.point.location,
        ],
      );

      if (kDebugMode) {
        print(
          'Polyline updated with new point (${event.point.location.latitude}, ${event.point.location.longitude}); total points: ${routePolyline.points.length}',
        );
      }

      emit(currentState.copyWith(routePolyline: routePolyline));
    }
  }

  void _onClearRoute(ClearRouteEvent event, Emitter<MapState> emit) {
    /* final currentState = state;
    if (currentState is MapLoadedState) {
      emit(
        currentState.copyWith(
          isRecordingRoute: false,
          routePolyline: defaultPolyline,
        ),
      );
    } */
    //  TODO: cal aquest esdeveniment?
  }

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    return super.close();
  }
}
