import 'dart:async';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' hide ClusterManager, Cluster;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/repositories/station_repository.dart';
import 'map_events.dart';
import 'map_state.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';


class MapBloc extends Bloc<MapEvent, MapState> {
  final StationRepository stationRepository;
  final Function(StationDetails, MapLoadedState) onMarkerTapped;
  
  // Stream de ubicación
  StreamSubscription<Position>? _positionStreamSubscription;
  
  // Posición central por defecto (Barcelona)
  static const LatLng _bcnCenter = LatLng(41.3851, 2.1734);

  MapBloc({
    required this.stationRepository,
    required this.onMarkerTapped,
  }) : super(const MapInitialState()) {
    // Registro de handlers para cada evento
    on<LoadMapDataEvent>(_onLoadMapData);
    on<ChangeModeEvent>(_onChangeMode);
    on<ToggleMapTypeEvent>(_onToggleMapType);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
    on<UpdateUserLocationEvent>(_onUpdateUserLocation);
    on<UpdateClustersEvent>(_onUpdateClusters);
  }

  Future<void> _onUpdateClusters(
  UpdateClustersEvent event,
  Emitter<MapState> emit) async {
    final currentState = state;
    if (currentState is MapLoadedState) {
      // Seleccionar el ClusterManager según el modo actual
      final clusterManager = currentState.currentMode == StationType.bicycle
          ? currentState.bikeClusterManager
          : currentState.evClusterManager;
      
      // Actualizar el mapa con el nuevo zoom
      if (clusterManager != null) {
        clusterManager.updateMap();
      }
    }
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

      final bikeClusterManager = await _initializeBikeClusterManager(bikeStations, emit);
      final evClusterManager = await _initializeEVClusterManager(evStations, emit);

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
        clusteredMarkers: {},
      ));

      // Iniciar solicitud de permisos de ubicación
      add(const RequestLocationPermissionEvent());
    } catch (e) {
      emit(MapErrorState('Error cargando estaciones: $e'));
    }
  }

  Future<ClusterManager<BicycleStationDetails>> _initializeBikeClusterManager(
    List<BicycleStationDetails> bikeStations,
    Emitter<MapState> emit,
  ) async {
    final bikeClusterManager = ClusterManager<BicycleStationDetails>(
      bikeStations,
      (markers) => _updateMarkers(markers, emit),
      markerBuilder: (cluster) => _bikeMarkerBuilder(cluster),
      levels: [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0], 
      extraPercent: 0.2,           
      stopClusteringZoom: 17,
    );

    return bikeClusterManager;
  }

  Future<ClusterManager<EVStationDetails>> _initializeEVClusterManager(
    List<EVStationDetails> evStations,
    Emitter<MapState> emit,
  ) async {

    final evClusterManager = ClusterManager<EVStationDetails>(
      evStations,
      (markers) => _updateMarkers(markers, emit),
      markerBuilder: (cluster) => _evMarkerBuilder(cluster),
      levels: [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0], 
      extraPercent: 0.2,           
      stopClusteringZoom: 17,
    );

    return evClusterManager;
  }

  Future<Marker> _bikeMarkerBuilder(Cluster<BicycleStationDetails> cluster) async {
    if(cluster.isMultiple){
      return Marker(
        markerId: MarkerId(cluster.getId()),
        position: cluster.location,
        icon: await _getClusterMarkerBitmap(cluster.count, Colors.blue),
      );
    } else {
      final station = cluster.items.first;
      return Marker(
        markerId: MarkerId(station.id),
        position: cluster.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }
  }

  Future<Marker> _evMarkerBuilder(Cluster<EVStationDetails> cluster) async {
    if(cluster.isMultiple){
      return Marker(
        markerId: MarkerId(cluster.getId()),
        position: cluster.location,
        icon: await _getClusterMarkerBitmap(cluster.count, Colors.green),
      );
    } else {
      final station = cluster.items.first;
      return Marker(
        markerId: MarkerId(station.id),
        position: cluster.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
    }
  }

  static Future<BitmapDescriptor> _getClusterMarkerBitmap(int size, Color color) async {
  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint1 = Paint()..color = color;

  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);

  
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: size.toString(),
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size/2 - textPainter.width / 2,   // Centrar horizontalmente
        size/2 - textPainter.height / 2,  // Centrar verticalmente
      ),
    );
  

  final img = await pictureRecorder.endRecording().toImage(size, size);
  final data = await img.toByteData(format: ImageByteFormat.png);

  return BitmapDescriptor.bytes(data!.buffer.asUint8List());
}

  void _updateMarkers(Set<Marker> markers, Emitter<MapState> emit) {
    if (state is MapLoadedState) {
      final currentState = state as MapLoadedState;
      emit(currentState.copyWith(clusteredMarkers: markers));
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
      add(const UpdateClustersEvent(12.0));
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

  /// Construir marcadores para una lista de estaciones
  Set<Marker> _buildMarkersForStations(
    List<BicycleStationDetails>? bikeStations,
    List<EVStationDetails>? evStations,
    BitmapDescriptor icon,
  ) {
    if(bikeStations == null && evStations != null){
      return evStations.where((station) => station.latitude != null && station.longitude != null).map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude!, station.longitude!),
        icon: icon,
        onTap: () => onMarkerTapped(station, state as MapLoadedState),
      );
    }).toSet();}
    else if(evStations == null && bikeStations != null){
      return bikeStations.where((station) => station.latitude != null && station.longitude != null).map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude!, station.longitude!),
        icon: icon,
        onTap: () => onMarkerTapped(station, state as MapLoadedState),
      );
    }).toSet();
    }

    return {};
    
  }

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    return super.close();
  }
}
