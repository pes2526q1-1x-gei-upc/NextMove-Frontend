import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/station_model.dart';
import 'map_events.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  //final StationRepository stationRepository;
  final Function(StationDetails) onMarkerTapped;
  
  // Stream de ubicación
  StreamSubscription<Position>? _positionStreamSubscription;
  
  // Posición central por defecto (Barcelona)
  static const LatLng _bcnCenter = LatLng(41.3851, 2.1734);

  MapBloc({
    //required this.stationRepository,
    required this.onMarkerTapped,
  }) : super(const MapInitialState()) {
    // Registro de handlers para cada evento
    on<LoadMapDataEvent>(_onLoadMapData);
    on<ChangeModeEvent>(_onChangeMode);
    on<ToggleMapTypeEvent>(_onToggleMapType);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
    on<UpdateUserLocationEvent>(_onUpdateUserLocation);
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
        getAllBicycleStationDetails(),
        getAllEVStationDetails(),
      ]);

      final bikeStations = results[0] as List<BicycleStationDetails>? ?? [];
      final evStations = results[1] as List<EVStationDetails>? ?? [];

      // Construir marcadores iniciales para bicicletas
      final bikeMarkers = _buildMarkersForStations(
        bikeStations,
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );

      final carMarkers = _buildMarkersForStations(
        evStations,
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );

      // Emitir estado cargado
      emit(MapLoadedState(
        bikeStations: bikeStations,
        evStations: evStations,
        userLocation: null,
        currentMode: StationType.bicycle,
        currentMapType: MapType.normal,
        bikeMarkers: bikeMarkers,
        carMarkers: carMarkers,
        centerPosition: _bcnCenter,
        searchQuery: null,
      ));

      // Iniciar solicitud de permisos de ubicación
      add(const RequestLocationPermissionEvent());
    } catch (e) {
      emit(MapErrorState('Error cargando estaciones: $e'));
    }
  }

  /// Handler: Cambiar modo (bicicleta/coche)
  void _onChangeMode(
    ChangeModeEvent event,
    Emitter<MapState> emit,
  ) {
    final currentState = state;
    if (currentState is MapLoadedState) {
      emit(currentState.copyWith(currentMode: event.newMode));
    }
  }

  /// Handler: Cambiar tipo de mapa (normal/satélite)
  void _onToggleMapType(
    ToggleMapTypeEvent event,
    Emitter<MapState> emit,
  ) {
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
        emit(const MapLocationPermissionDeniedState(isPermanentlyDenied: false));
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

  /// Iniciar actualizaciones de ubicación
  void _startLocationUpdates() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50, // Actualizar cada 50 metros
    );

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(
      (Position? pos) {
        if(pos != null && !isClosed){
          add(UpdateUserLocationEvent(
            latitude: pos.latitude,
            longitude: pos.longitude,
          ));
        }
      },
      onError: (error) {
        print('Error en stream de ubicación: $error');

      },
      cancelOnError: false,
    );
  }

  /// Construir marcadores para una lista de estaciones
  Set<Marker> _buildMarkersForStations(
    List<StationDetails> stations,
    BitmapDescriptor icon,
  ) {
    return stations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude, station.longitude),
        icon: icon,
        onTap: () => onMarkerTapped(station),
      );
    }).toSet();
  }

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    return super.close();
  }
}
