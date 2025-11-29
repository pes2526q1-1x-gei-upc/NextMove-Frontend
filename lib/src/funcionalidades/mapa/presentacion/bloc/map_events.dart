import 'package:equatable/equatable.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';

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
  final double altitude;

  const UpdateUserLocationEvent({
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });

  @override
  List<Object?> get props => [latitude, longitude, altitude];
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

//Evento: Consulta de estaciones al backend según la barra de búsqueda
class SearchStationsEvent extends MapEvent {
  final String query;

  const SearchStationsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchEvent extends MapEvent {
  
  const ClearSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: iniciar grabación de ruta
class StartRouteRecordingEvent extends MapEvent {
  const StartRouteRecordingEvent();
}

/// Evento: detener grabación de ruta
class StopRouteRecordingEvent extends MapEvent {
  const StopRouteRecordingEvent();
}

/// Evento: agregar punto a la ruta actual
class AddRoutePointEvent extends MapEvent {
  final TrackPoint point;

  const AddRoutePointEvent(this.point);

  @override
  List<Object?> get props => [point];
}

/// Evento: actualizar tiempo transcurrido de grabación
class UpdateRecordingElapsedTimeEvent extends MapEvent {
  const UpdateRecordingElapsedTimeEvent();
}
