import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';

/// Clase base abstracta para todos los estados del mapa
abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial: cuando la aplicación arranca
class MapInitialState extends MapState {
  const MapInitialState();
}

/// Estado de carga: mientras se cargan estaciones y ubicación
class MapLoadingState extends MapState {
  const MapLoadingState();
}

/// Estado cargado con éxito: contiene todos los datos necesarios
class MapLoadedState extends MapState {
  final List<StationDetails> bikeStations;
  final List<StationDetails> evStations;
  final LatLng? userLocation;
  final StationType currentMode;
  final MapType currentMapType;
  final Set<Marker> bikeMarkers;
  final Set<Marker> carMarkers;
  final LatLng centerPosition;
  final String? searchQuery;
  final List<StationDetails> searchResults;
  final bool isSearching;
  final bool isRecordingRoute;
  final RecordedTrack? recordedTrack;
  final Polyline routePolyline;
  final String? snackbarError;
  final Duration recordingElapsedTime;

  const MapLoadedState({
    required this.bikeStations,
    required this.evStations,
    this.userLocation,
    required this.currentMode,
    required this.currentMapType,
    required this.bikeMarkers,
    required this.carMarkers,
    required this.centerPosition,
    this.searchQuery,
    this.searchResults = const [],
    required this.isSearching,
    this.isRecordingRoute = false,
    this.recordedTrack,
    required this.routePolyline,
    this.snackbarError,
    this.recordingElapsedTime = Duration.zero,
  });

  @override
  List<Object?> get props => [
        bikeStations,
        evStations,
        userLocation,
        currentMode,
        currentMapType,
        bikeMarkers,
        carMarkers,
        centerPosition,
        searchQuery,
        searchResults,
        isSearching,
        isRecordingRoute,
        recordedTrack,
        routePolyline,
        snackbarError,
        recordingElapsedTime,
      ];

  /// Método copyWith para actualizar el estado inmutablemente
  MapLoadedState copyWith({
    List<StationDetails>? bikeStations,
    List<StationDetails>? evStations,
    LatLng? userLocation,
    StationType? currentMode,
    MapType? currentMapType,
    Set<Marker>? bikeMarkers,
    Set<Marker>? carMarkers,
    LatLng? centerPosition,
    String? searchQuery,
    List<StationDetails>? searchResults,
    bool? isSearching,
    bool? isRecordingRoute,
    RecordedTrack? recordedTrack,
    Polyline? routePolyline,
    String? snackbarError,
    Duration? recordingElapsedTime,
  }) {
    return MapLoadedState(
      bikeStations: bikeStations ?? this.bikeStations,
      evStations: evStations ?? this.evStations,
      userLocation: userLocation ?? this.userLocation,
      currentMode: currentMode ?? this.currentMode,
      currentMapType: currentMapType ?? this.currentMapType,
      bikeMarkers: bikeMarkers ?? this.bikeMarkers,
      carMarkers: carMarkers ?? this.carMarkers,
      centerPosition: centerPosition ?? this.centerPosition,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      isRecordingRoute: isRecordingRoute ?? this.isRecordingRoute,
      recordedTrack: recordedTrack ?? this.recordedTrack,
      routePolyline: routePolyline ?? this.routePolyline,
      snackbarError: snackbarError ?? this.snackbarError,
      recordingElapsedTime: recordingElapsedTime ?? this.recordingElapsedTime,
    );
  }

}

/// Estado de error: cuando algo falla
class MapErrorState extends MapState {
  final String message;

  const MapErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de permisos de ubicación denegados
class MapLocationPermissionDeniedState extends MapState {
  final bool isPermanentlyDenied;

  const MapLocationPermissionDeniedState({
    this.isPermanentlyDenied = false,
  }); 

  @override
  List<Object?> get props => [isPermanentlyDenied];
}
