import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/repositories/station_repository.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/repositories/navigation_route_repository.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/repositories/track_repository.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/data/repositories/recorded_routes_repository.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/services/search_history_service.dart';
import 'package:nextmove_app/src/shared/domain/route_input.dart';
import 'package:nextmove_app/src/shared/enums/route_input_enums.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/stations_cache.dart';
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
  final RecordedRoutesRepository recordedRoutesRepository;
  final SearchHistoryService searchHistoryService;
  final NavigationRouteRepository navigationRouteRepository;
  final StationsCache stationsCache;
  final Function(StationDetails, MapLoadedState) onMarkerTapped;

  // Stream de ubicación
  StreamSubscription<Position>? _positionStreamSubscription;

  // Timer para actualizar el tiempo transcurrido durante la grabación
  Timer? _recordingTimer;

  // Posición central por defecto (Barcelona)
  static const LatLng _bcnCenter = LatLng(41.3851, 2.1734);

  final StationType? _initialMode;


  static const Size bikeIconSize = Size(60, 60);  
  static const Size evIconSize = Size(20, 20);     

  BitmapDescriptor? evLowIcon;
  BitmapDescriptor? evMidIcon;
  BitmapDescriptor? evHighIcon;
  BitmapDescriptor? evSuperIcon;
  BitmapDescriptor? bikeIcon;

  MapBloc({
    required this.stationRepository,
    required this.trackRepository,
    required this.recordedRoutesRepository,
    required this.navigationRouteRepository,
    required this.searchHistoryService,
    required this.stationsCache,
    required this.onMarkerTapped,
    StationType? initialMode,
  }) : _initialMode = initialMode,
       super(const MapInitialState()) {
    // Registro de handlers para cada evento
    on<LoadMapDataEvent>(_onLoadMapData);
    on<ChangeModeEvent>(_onChangeMode);
    on<ToggleMapTypeEvent>(_onToggleMapType);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
    on<UpdateUserLocationEvent>(_onUpdateUserLocation);
    on<SearchStationsEvent>(_onSearchStations);
    on<SelectSearchResultEvent>(_onSelectSearchResult); 
    on<ClearSearchEvent>(_onClearSearch);
    on<StartRouteRecordingEvent>(_onStartRouteRecording);
    on<StopRouteRecordingEvent>(_onStopRouteRecording);
    on<AddRoutePointEvent>(_onAddRoutePoint);
    on<UpdateRecordingElapsedTimeEvent>(_onUpdateRecordingElapsedTime);
    on<ShowRouteToStationEvent>(_onShowRouteToStation);
    on<CancelNavigationEvent>(_onCancelNavigation);
    on<StartTurnByTurnNavigationEvent>(_onStartTurnByTurnNavigation);
    on<StopTurnByTurnNavigationEvent>(_onStopTurnByTurnNavigation);
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

      // Crear ClusterManagerIds
      final bikeClusterManagerId = ClusterManagerId('bike_cluster_manager');
      final evClusterManagerId = ClusterManagerId('ev_cluster_manager');

      // Crear ClusterManagers
      final bikeClusterManager = ClusterManager(
        clusterManagerId: bikeClusterManagerId,
        onClusterTap: (Cluster cluster) {
          if (kDebugMode) {
            debugPrint('🔵 Cluster de bicicletas tapped: ${cluster.count} estaciones');
          }
        },
      );

      final evClusterManager = ClusterManager(
        clusterManagerId: evClusterManagerId,
        onClusterTap: (Cluster cluster) {
          if (kDebugMode) {
            debugPrint('🟢 Cluster de EV tapped: ${cluster.count} estaciones');
          }
        },
      );

      bikeIcon = await _getBikeCustomIcon();
      await _loadEvCustomIcons();

      final bikeMarkers = _buildMarkersForStations(
        bikeStations,
        null,
        bikeClusterManagerId,
      );

      final carMarkers = _buildMarkersForStations(
        null,
        evStations,
        evClusterManagerId,
      );

      // Cargar búsquedas recientes guardadas
      final savedBikeSearchIds = await searchHistoryService.getBikeSearches();
      final savedEvSearchIds = await searchHistoryService.getEvSearches();

      // Recuperar objetos completos de estaciones desde los IDs guardados
      final recentBikeSearches = _recoverStationsFromIds(
        savedBikeSearchIds,
        bikeStations,
      );
      final recentEvSearches = _recoverStationsFromIds(
        savedEvSearchIds,
        evStations,
      );

      // Determinar el modo inicial: usar el modo preferido del usuario o bici por defecto
      final initialMode = _initialMode ?? StationType.bicycle;

      // Emitir estado cargado
      emit(
        MapLoadedState(
          bikeStations: bikeStations,
          evStations: evStations,
          userLocation: null,
          currentMode: initialMode,
          currentMapType: MapType.normal,
          bikeMarkers: bikeMarkers,
          carMarkers: carMarkers,
          centerPosition: _bcnCenter,
          searchQuery: null,
          searchResults: [],
          isSearching: false,
          routePolyline: defaultPolyline,
          recentBikeSearches: recentBikeSearches,  
          recentEvSearches: recentEvSearches,     
          decodedPolyline: null,
          bikeClusterManager: bikeClusterManager,
          evClusterManager: evClusterManager,
        ),
      );

      // Update cache
      stationsCache.updateStations([...bikeStations, ...evStations]);

      // Iniciar solicitud de permisos de ubicación
      add(const RequestLocationPermissionEvent());
    } catch (e) {
      emit(MapErrorState('Error cargando estaciones: $e'));
    }
  }
  List<StationDetails> _recoverStationsFromIds(
    List<String> stationIds,
    List<StationDetails> allStations,
  ) {

    final Map<String, StationDetails> stationMap = {
      for (var station in allStations) station.id: station
    };

    return stationIds
        .where((id) => stationMap.containsKey(id))
        .map((id) => stationMap[id]!)
        .toList();
  }

  void _onSelectSearchResult(
    SelectSearchResultEvent event,
    Emitter<MapState> emit,
  ) async {
    final currentState = state;
    if (currentState is MapLoadedState) {
      final selectedStation = event.selectedStation;

      List<StationDetails> updatedRecentSearches;
      
      if (currentState.currentMode == StationType.bicycle) {
        updatedRecentSearches = _addToRecentSearches(
          currentState.recentBikeSearches,
          selectedStation,
        );
        
        final stationIds = updatedRecentSearches.map((s) => s.id).toList();
        await searchHistoryService.saveBikeSearches(stationIds);
        
        
        emit(currentState.copyWith(
          recentBikeSearches: updatedRecentSearches,
          clearSearchQuery: true,
          searchResults: [],
          isSearching: false,
        ));
        
      } else {
        updatedRecentSearches = _addToRecentSearches(
          currentState.recentEvSearches,
          selectedStation,
        );
        
        final stationIds = updatedRecentSearches.map((s) => s.id).toList();
        await searchHistoryService.saveEvSearches(stationIds);
        
        
        emit(currentState.copyWith(
          recentEvSearches: updatedRecentSearches,
          clearSearchQuery: true,
          searchResults: [],
          isSearching: false,
        ));
        
      }

      final updatedState = state as MapLoadedState;
      onMarkerTapped(selectedStation, updatedState);

      if (kDebugMode) {
        print('Estación seleccionada: ${selectedStation.name} (${selectedStation.id})');
        print('Búsquedas recientes guardadas: ${updatedRecentSearches.length}');
      }
    }
  }

  /// Añadir estación a búsquedas recientes (máximo 5, sin duplicados)
  List<StationDetails> _addToRecentSearches(
    List<StationDetails> currentSearches,
    StationDetails newStation,
  ) {
    final List<StationDetails> filteredSearches = currentSearches
        .where((station) => station.id != newStation.id)
        .toList();

    final List<StationDetails> updatedSearches = [
      newStation,
      ...filteredSearches,
    ];

    return updatedSearches.take(5).toList();
  }

  /// Handler: Cambiar modo (bicicleta/coche)
  void _onChangeMode(ChangeModeEvent event, Emitter<MapState> emit) {
    final currentState = state;
    if (currentState is MapLoadedState) {
      emit(currentState.copyWith(
      currentMode: event.newMode,
      clearSearchQuery: true,
      searchResults: [],
      isSearching: false,
    ));
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

      // Turn-by-turn navigation logic
      if (currentState.isTurnByTurnActive && 
          currentState.navigationRoute != null && 
          currentState.currentStepIndex != null) {
        final route = currentState.navigationRoute!;
        final currentStepIndex = currentState.currentStepIndex!;
        
        if (currentStepIndex < route.steps.length) {
          final currentStep = route.steps[currentStepIndex];
          
          // Calculate distance to end of current step
          if (currentStep.endLocation != null) {
            final distanceToStepEnd = Geolocator.distanceBetween(
              newLocation.latitude,
              newLocation.longitude,
              currentStep.endLocation!.latitude,
              currentStep.endLocation!.longitude,
            ).round();
            
            // Check if we should advance to next step (within 30 meters)
            if (distanceToStepEnd < 30 && currentStepIndex < route.steps.length - 1) {
              // Advance to next step
              if (kDebugMode) {
                print('Advancing to step ${currentStepIndex + 1}');
              }
              emit(currentState.copyWith(
                userLocation: newLocation,
                currentStepIndex: currentStepIndex + 1,
                distanceToNextStepMeters: 0,
                userHeading: event.heading >= 0 ? event.heading : null,
              ));
              return;
            } else if (distanceToStepEnd < 20 && currentStepIndex == route.steps.length - 1) {
              // Arrived at destination
              if (kDebugMode) {
                print('Arrived at destination!');
              }
              emit(currentState.copyWith(
                userLocation: newLocation,
                isTurnByTurnActive: false,
                currentStepIndex: null,
                distanceToNextStepMeters: null,
                userHeading: null,
              ));
              return;
            }
            
            // Update distance to next step and heading
            emit(currentState.copyWith(
              userLocation: newLocation,
              distanceToNextStepMeters: distanceToStepEnd,
              userHeading: event.heading >= 0 ? event.heading : null,
            ));
            return;
          }
        }
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
            clearSearchQuery: true,
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
            : await stationRepository.searchBicycleStations(query);

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
                  heading: pos.heading,
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
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      );
      Position currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      add(
        UpdateUserLocationEvent(
          latitude: currentPosition.latitude,
          longitude: currentPosition.longitude,
          altitude: currentPosition.altitude,
          heading: currentPosition.heading,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current position: $e');
      }
    }
  }

 
  Future<BitmapDescriptor> _getBikeCustomIcon() async {
    final targetSize = Platform.isIOS ? const Size(75, 75) : const Size(75, 75);
    final ByteData data = await rootBundle.load('assets/bikePin_custom.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetSize.width.toInt(),
      targetHeight: targetSize.height.toInt(),
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedBytes = byteData!.buffer.asUint8List();
    return BitmapDescriptor.bytes(resizedBytes);
  }

  Future<void> _loadEvCustomIcons() async {
    final targetSize = Platform.isIOS ? const Size(75, 75) : const Size(75, 75);
    final targetWidth = targetSize.width.toInt();
    final targetHeight = targetSize.height.toInt();
    
    evLowIcon = await _loadEvIcon('assets/evLow_icon.png', targetWidth, targetHeight);
    evMidIcon = await _loadEvIcon('assets/evMid_icon.png', targetWidth, targetHeight);
    evHighIcon = await _loadEvIcon('assets/evHigh_icon.png', targetWidth, targetHeight);
    evSuperIcon = await _loadEvIcon('assets/evSuper_icon.png', targetWidth, targetHeight);
  }

  Future<BitmapDescriptor> _loadEvIcon(String assetPath, int width, int height) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: width,
      targetHeight: height,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedBytes = byteData!.buffer.asUint8List();
    return BitmapDescriptor.bytes(resizedBytes);
  }

  double _getMaxPowerKw(List<Connector>? connectors) {
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

  BitmapDescriptor _getCarIconByPower(double powerKw, bool isSuperFast) {
    if (isSuperFast) {
      return evSuperIcon!;
    }
    
    if (powerKw <= 11) {
      return evLowIcon!;
    } else if (powerKw <= 22) {
      return evMidIcon!;
    } else if (powerKw <= 50) {
      return evHighIcon!;
    } else {
      return evSuperIcon!;
    }
  }

  
  Set<Marker> _buildMarkersForStations(
    List<BicycleStationDetails>? bikeStations,
    List<EVStationDetails>? evStations,
    ClusterManagerId clusterManagerId,
  ) {
    if (bikeStations == null && evStations != null) {
      return evStations
          .where(
            (station) => station.latitude != null && station.longitude != null,
          )
          .map((station) {
            final power = _getMaxPowerKw(station.connectors);
            final icon = _getCarIconByPower(power, station.isSuperFast == true);
            
            return Marker(
              markerId: MarkerId(station.id),
              position: LatLng(station.latitude!, station.longitude!),
              icon: icon,
              clusterManagerId: clusterManagerId,
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
              icon: bikeIcon!,
              clusterManagerId: clusterManagerId,
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
          snackbarError: null,
          recordingElapsedTime: Duration.zero,
        ),
      );

      // Iniciar timer para actualizar el tiempo transcurrido
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        add(const UpdateRecordingElapsedTimeEvent());
      });

      if (kDebugMode) {
        print('Polyline reset for route recording start');
      }
    }
  }

  void _onStopRouteRecording(
    StopRouteRecordingEvent event,
    Emitter<MapState> emit,
  ) async {
    // Cancelar el timer de grabación
    _recordingTimer?.cancel();
    _recordingTimer = null;

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
            snackbarError: 'not-enough-points',
          ),
        );
        emit(
          currentState.copyWith(
            isRecordingRoute: false,
            routePolyline: defaultPolyline,
            snackbarError: null,
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
          }
          emit(
            currentState.copyWith(
              isRecordingRoute: false,
              routePolyline: defaultPolyline,
              snackbarError: failure.message,
            ),
          );
          emit(
            currentState.copyWith(
              isRecordingRoute: false,
              routePolyline: defaultPolyline,
              snackbarError: null,
            ),
          );
        },
        (_) {
          if (kDebugMode) {
            print('Recorded track saved successfully.');
          }
          emit(
            currentState.copyWith(
              isRecordingRoute: false,
              routePolyline: defaultPolyline,
              snackbarError: null,
            ),
          );
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

  void _onUpdateRecordingElapsedTime(
    UpdateRecordingElapsedTimeEvent event,
    Emitter<MapState> emit,
  ) {
    final currentState = state;
    if (currentState is MapLoadedState && currentState.isRecordingRoute) {
      final newElapsedTime = currentState.recordingElapsedTime + const Duration(seconds: 1);
      if (kDebugMode) {
        print('Recording elapsed time: ${newElapsedTime.inSeconds} seconds');
      }
      emit(currentState.copyWith(
        recordingElapsedTime: newElapsedTime,
      ));
    }
  }

  void _onShowRouteToStation (
    ShowRouteToStationEvent event,
    Emitter<MapState> emit,
  ) async{
    final currentState = state;
    if (currentState is MapLoadedState) {
      
      emit(currentState.copyWith(
        isNavigationMode: true,
        selectedStation: event.station,
        searchQuery: null,
        searchResults: [],
      ));

      final routeInput = RouteInput(
        origin: currentState.userLocation!, 
        destination: LatLng(event.station.latitude!, event.station.longitude!),  
        mode: currentState.currentMode == StationType.bicycle ? TravelModeEnum.BICYCLE : TravelModeEnum.DRIVE, 
        routingPreference: RoutingPreferenceEnum.TRAFFIC_AWARE,
        language: currentState.currentLanguage,
      );

      try{
          final result = await navigationRouteRepository.fetchNavigationRoute(routeInput);

          if(emit.isDone){
            debugPrint('Bloc closed, aborting navigation route fetch.');
            return;
          }
          result.fold(
            (failure) {
              if (kDebugMode) {
                print('Error fetching navigation route: ${failure.message}');
              }
            },
            (navigationRoute) {
              if (kDebugMode) {
                print('Navigation route fetched successfully.');
              }
              final List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(navigationRoute.polyline);

              final List<LatLng> polylinePointsCoordinates = decodedPoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

              // 3. Crear el objeto Polyline
              final Polyline navigationPolyline = Polyline(
                polylineId: const PolylineId('navigation_route'),
                points: polylinePointsCoordinates,
                color:  currentState.currentMode == StationType.bicycle ? Colors.blue : Colors.green,
                width: 5,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              );

              emit(currentState.copyWith(
                navigationRoute: navigationRoute,
                decodedPolyline: navigationPolyline,
                routeViewport: navigationRoute.viewport,
                isNavigationMode: true,
                selectedStation: event.station,
                searchQuery: null,
                searchResults: [],
              ));
            },
          );
          } catch (e) {
            if (kDebugMode) {
              print('Error fetching navigation route: $e');
            }
          }

    }

    
  }

  void _onCancelNavigation(
    CancelNavigationEvent event,
    Emitter<MapState> emit,
  ) {
    final currentState = state;
    if (currentState is MapLoadedState) {
      emit(currentState.copyWith(
        isNavigationMode: false,
        selectedStation: null,
        navigationRoute: null,
        decodedPolyline: Polyline(polylineId: PolylineId('no_route')),
        routeViewport: null,
        isTurnByTurnActive: false,
        currentStepIndex: null,
        distanceToNextStepMeters: null,
      ));
    }
  }

  /// Handler: Iniciar navegación turn-by-turn
  void _onStartTurnByTurnNavigation(
    StartTurnByTurnNavigationEvent event,
    Emitter<MapState> emit,
  ) {
    final currentState = state;
    if (currentState is MapLoadedState && 
        currentState.navigationRoute != null &&
        currentState.navigationRoute!.steps.isNotEmpty) {
      if (kDebugMode) {
        print('Starting turn-by-turn navigation with ${currentState.navigationRoute!.steps.length} steps');
      }
      
      // Calculate initial distance to first step
      int? initialDistance;
      if (currentState.userLocation != null && 
          currentState.navigationRoute!.steps[0].endLocation != null) {
        initialDistance = Geolocator.distanceBetween(
          currentState.userLocation!.latitude,
          currentState.userLocation!.longitude,
          currentState.navigationRoute!.steps[0].endLocation!.latitude,
          currentState.navigationRoute!.steps[0].endLocation!.longitude,
        ).round();
      }
      
      emit(currentState.copyWith(
        isTurnByTurnActive: true,
        currentStepIndex: 0,
        distanceToNextStepMeters: initialDistance ?? 0,
      ));
    }
  }

  /// Handler: Detener navegación turn-by-turn
  void _onStopTurnByTurnNavigation(
    StopTurnByTurnNavigationEvent event,
    Emitter<MapState> emit,
  ) {
    final currentState = state;
    if (currentState is MapLoadedState) {
      if (kDebugMode) {
        print('Stopping turn-by-turn navigation');
      }
      
      emit(currentState.copyWith(
        isTurnByTurnActive: false,
        currentStepIndex: null,
        distanceToNextStepMeters: null,
      ));
    }
  }

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    return super.close();
  }
}

