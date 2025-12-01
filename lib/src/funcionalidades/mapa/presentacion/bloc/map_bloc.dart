import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/repositories/station_repository.dart';
import 'map_events.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final StationRepository stationRepository;
  final Function(StationDetails, MapLoadedState) onMarkerTapped;
  BitmapDescriptor? evLowIcon;
  BitmapDescriptor? evMidIcon;
  BitmapDescriptor? evHighIcon;
  BitmapDescriptor? evSuperIcon;
  
  // Stream de ubicación
  StreamSubscription<Position>? _positionStreamSubscription;

  Set<Marker> carMarkers = {};
  Set<Marker> bikeMarkers = {};

  
  // Posición central por defecto (Barcelona)
  static const LatLng _bcnCenter = LatLng(41.3851, 2.1734);

  MapBloc({
    required this.stationRepository,
    required this.onMarkerTapped,
    this.evLowIcon,
    this.evMidIcon,
    this.evHighIcon,
    this.evSuperIcon,
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
        stationRepository.getAllBicycleStationDetails(),
        stationRepository.getAllEVStationDetails(),
      ]);

     

      final bikeStations = results[0].fold((failure) => 
        throw Exception('Error cargando estaciones de bicicletas: ${failure.message}')
      ,(stations) => stations as List<BicycleStationDetails>? ?? []);
      final evStations = results[1].fold((failure) => 
        throw Exception('Error cargando estaciones de coches: ${failure.message}')
      ,(stations) => stations as List<EVStationDetails>? ?? []);

      final bikeClusterManagerId = ClusterManagerId('bike_cluster_manager');
      final evClusterManagerId = ClusterManagerId('ev_cluster_manager');

      final bikeClusterManager = ClusterManager(
          clusterManagerId: bikeClusterManagerId,
          onClusterTap: (Cluster cluster) {
            // Manejar toque en clúster de bicicletas
            debugPrint('🔵 Cluster de bicicletas tapped: ${cluster.count} estaciones');
          },
      );

      final evClusterManager = ClusterManager(
      clusterManagerId: evClusterManagerId,
      onClusterTap: (Cluster cluster) {
        debugPrint('🟢 Cluster de EV tapped: ${cluster.count} estaciones');
      },
    );
      
      final bikeIcon = await _getBikeCustomIcon();
      await _loadEvCustomIcons();
  
      // Construir marcadores iniciales para bicicletas
      bikeMarkers = _buildMarkersWithClusterForBike(
        bikeStations,
        bikeClusterManagerId,
        bikeIcon,
      );

      carMarkers = _buildMarkersWithClusterForEv(
        evStations,
        evClusterManagerId,
      );
      debugPrint('CarsMarkers created: ${carMarkers.length}');

      

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
        bikeClusterManager: bikeClusterManager,
        evClusterManager: evClusterManager,
      ));

      // Iniciar solicitud de permisos de ubicación
      add(const RequestLocationPermissionEvent());
    } catch (e) {
      emit(MapErrorState('Error cargando estaciones: $e'));
    }
  }

  Set<Marker> _buildMarkersWithClusterForBike(
  List<BicycleStationDetails> stations,
  ClusterManagerId clusterManagerId,
  BitmapDescriptor icon,
  ) {
    return stations
        .where((station) => station.latitude != null && station.longitude != null)
        .map((station) {
          return Marker(
            markerId: MarkerId(station.id),
            position: LatLng(station.latitude!, station.longitude!),
            icon: icon,
            clusterManagerId: clusterManagerId, 
            onTap: () => onMarkerTapped(station, state as MapLoadedState),
          );
        }).toSet();
  }

  Set<Marker> _buildMarkersWithClusterForEv(
  List<EVStationDetails> stations,
  ClusterManagerId clusterManagerId,
  ) {
    return stations
        .where((station) => station.latitude != null && station.longitude != null)
        .map((station) {
          final power = _getMaxPowerKw(station.connectors);
          final icon = getCarIconByPower(power);  // ← CACHEAR AQUÍ

          return Marker(
            markerId: MarkerId(station.id),
            position: LatLng(station.latitude!, station.longitude!),
            icon: icon, // Usar siempre el icono de baja potencia por ahora
            clusterManagerId: clusterManagerId, 
            onTap: () => onMarkerTapped(station, state as MapLoadedState),
          );
        }).toSet();
  }

  _getMaxPowerKw(List<Connector>? connectors) {
    if (connectors == null || connectors.isEmpty) {
      return 0.0;
    }
    double maxPower = 0.0;
    for (var connector in connectors) {
      if (connector.powerKw != null && connector.powerKw! > maxPower) {
        maxPower = connector.powerKw!;
      }
    }
    return maxPower;
  }

  Future<BitmapDescriptor> _getBikeCustomIcon() async {
      return await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(60, 60)),  // Tamaño ajustable
        'assets/bikePin_custom.png',
      );
  }

  Future<void> _loadEvCustomIcons() async {
  
    evLowIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      'assets/evLow_icon.png',
    );
    debugPrint('EV Low Icon loaded');

    evMidIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      'assets/evMid_icon.png',
    );
    debugPrint('EV Mid Icon loaded');

    evHighIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      'assets/evHigh_icon.png',
    );
    debugPrint('EV High Icon loaded');

    evSuperIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      'assets/evSuper_icon.png',
    );
    debugPrint('EV Super Icon loaded');
  
}

  BitmapDescriptor getCarIconByPower(double powerKw) {
  if (powerKw <= 11) {
    debugPrint('Using EV Low Icon for power: $powerKw kW');
    return evLowIcon!;
  } else if (powerKw <= 22) {
    debugPrint('Using EV Mid Icon for power: $powerKw kW');
    return evMidIcon!;
  } else if (powerKw <= 50) {
    debugPrint('Using EV High Icon for power: $powerKw kW');
    return evHighIcon!;
  } else {
    debugPrint('Using EV Super Icon for power: $powerKw kW');
    return evSuperIcon!;
  }
}


  
  /// Handler: Cambiar modo (bicicleta/coche)
  void _onChangeMode(
    ChangeModeEvent event,
    Emitter<MapState> emit,
  ) {
    final currentState = state;
    if (currentState is MapLoadedState) {
      

    // ✅ Crear SOLO los marcadores del modo seleccionado
    /*if (event.newMode == StationType.bicycle) {
      bikeMarkersToShow = currentState.bikeMarkers;  // Usar los cacheados
      carMarkersToShow = const {};  // VACÍO
    } else {
      bikeMarkersToShow = const {};  // VACÍO
      if(carMarkers.isEmpty){ 
          carMarkers = _buildMarkersWithClusterForEv(
          currentState.evStations as List<EVStationDetails>,
          currentState.evClusterManager!.clusterManagerId, 
        );
      }
      carMarkersToShow = carMarkers;  // Usar los cacheados
    }*/


    emit(currentState.copyWith(
      currentMode: event.newMode,
      bikeMarkers: event.newMode == StationType.bicycle ? bikeMarkers : {},
      carMarkers: event.newMode == StationType.electricVehicle ? carMarkers : {},
    ));
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
        if (kDebugMode) {
          print('Error en stream de ubicación: $error');
        }

      },
      cancelOnError: false,
    );
  }


  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    return super.close();
  }
}
