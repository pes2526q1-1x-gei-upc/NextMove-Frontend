import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

/// Clase base abstracta para todos los eventos del mapa
abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Evento inicial: cargar estaciones y ubicación
class LoadMapDataEvent extends MapEvent {
  const LoadMapDataEvent();
}

/// Evento: cambiar modo entre bicicleta y coche eléctrico
class ChangeModeEvent extends MapEvent {
  final StationType newMode;

  const ChangeModeEvent(this.newMode);

  @override
  List<Object?> get props => [newMode];
}

/// Evento: cambiar tipo de mapa (normal/satélite)
class ToggleMapTypeEvent extends MapEvent {
  const ToggleMapTypeEvent();
}

/// Evento: actualización de ubicación del usuario
class UpdateUserLocationEvent extends MapEvent {
  final double latitude;
  final double longitude;

  const UpdateUserLocationEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Evento: solicitar permisos de ubicación
class RequestLocationPermissionEvent extends MapEvent {
  const RequestLocationPermissionEvent();
}

/// Evento: mostrar bottom sheet de detalles de estación
class ShowStationDetailsEvent extends MapEvent {
  final StationDetails station;

  const ShowStationDetailsEvent(this.station);

  @override
  List<Object?> get props => [station];
}

class UpdateClustersEvent extends MapEvent {
  final double zoom;

  const UpdateClustersEvent(this.zoom);

  @override
  List<Object?> get props => [zoom];
}

class UpdateClusteredMarkersEvent extends MapEvent {
  final Set<Marker> markers;
  
  const UpdateClusteredMarkersEvent(this.markers);
  
  @override
  List<Object> get props => [markers];
}