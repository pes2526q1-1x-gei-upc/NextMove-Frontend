import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

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
  final Set<Marker> markers;
  final LatLng centerPosition;
  final String? searchQuery;

  const MapLoadedState({
    required this.bikeStations,
    required this.evStations,
    this.userLocation,
    required this.currentMode,
    required this.currentMapType,
    required this.markers,
    required this.centerPosition,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
        bikeStations,
        evStations,
        userLocation,
        currentMode,
        currentMapType,
        markers,
        centerPosition,
        searchQuery,
      ];

  /// Método copyWith para actualizar el estado inmutablemente
  MapLoadedState copyWith({
    List<StationDetails>? bikeStations,
    List<StationDetails>? evStations,
    LatLng? userLocation,
    StationType? currentMode,
    MapType? currentMapType,
    Set<Marker>? markers,
    LatLng? centerPosition,
    String? searchQuery,
  }) {
    return MapLoadedState(
      bikeStations: bikeStations ?? this.bikeStations,
      evStations: evStations ?? this.evStations,
      userLocation: userLocation ?? this.userLocation,
      currentMode: currentMode ?? this.currentMode,
      currentMapType: currentMapType ?? this.currentMapType,
      markers: markers ?? this.markers,
      centerPosition: centerPosition ?? this.centerPosition,
      searchQuery: searchQuery ?? this.searchQuery,
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
