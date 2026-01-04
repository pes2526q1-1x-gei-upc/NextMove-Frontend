import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/recording_track_statistics_page.dart';

class MapControlsColumnWidget extends StatelessWidget {
  final LatLng? userLocation;
  final GoogleMapController? mapController;
  final MapType currentMapType;
  final Function(CameraPosition)? onBeforeToggleMapType;

  const MapControlsColumnWidget({
    super.key,
    this.userLocation,
    this.mapController,
    required this.currentMapType,
    this.onBeforeToggleMapType,
  });

  void _centerOnUser() {
    if (userLocation != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(userLocation!.latitude, userLocation!.longitude),
          15,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final iconColor = theme.colorScheme.onSurface;
    final List<BoxShadow> commonShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
        spreadRadius: 1,
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ];

    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is! MapLoadedState) {
          return const SizedBox.shrink();
        }

        final isRecording = state.isRecordingRoute;
        // Si está en modo bici, los botones deben estar más arriba para dejar espacio al botón de play
        // Si está en modo coche, los botones están en la parte inferior
        final bottomOffset = (state.currentMode == StationType.bicycle) ? 90.0 : 30.0;
        
        return Positioned(
          bottom: bottomOffset,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: state.currentMode == StationType.bicycle 
                ? MainAxisAlignment.end 
                : MainAxisAlignment.start,
            children: [
              // Satellite/Map toggle button
              GestureDetector(
                onTap: () async {
                  // Capturar la posición actual de la cámara antes de cambiar el tipo
                  if (mapController != null && onBeforeToggleMapType != null) {
                    try {
                      final visibleRegion = await mapController!.getVisibleRegion();
                      final zoom = await mapController!.getZoomLevel();
                      final center = LatLng(
                        (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
                        (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
                      );
                      onBeforeToggleMapType!(CameraPosition(
                        target: center,
                        zoom: zoom,
                      ));
                    } catch (e) {
                      // Si hay error, continuar sin capturar la posición
                    }
                  }
                  // Verificar que el contexto sigue montado antes de usarlo
                  if (context.mounted) {
                    context.read<MapBloc>().add(const ToggleMapTypeEvent());
                  }
                },
                child: Container(
                  height: 50,
                  width: 50,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                    boxShadow: commonShadow,
                  ),
                  child: Icon(
                    currentMapType == MapType.normal
                        ? Icons.satellite
                        : Icons.map,
                    color: iconColor,
                    size: 28,
                  ),
                ),
              ),

              // Current location button
              GestureDetector(
                onTap: _centerOnUser,
                child: Container(
                  height: 50,
                  width: 50,
                  margin: state.currentMode == StationType.bicycle
                      ? const EdgeInsets.only(bottom: 10)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                    boxShadow: commonShadow,
                  ),
                  child: Icon(Icons.my_location, color: iconColor, size: 28),
                ),
              ),

              // Statistics button (only when recording and in bicycle mode)
              if (isRecording && state.currentMode == StationType.bicycle) ...[
                GestureDetector(
                  onTap: () {
                    final mapBloc = context.read<MapBloc>();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: mapBloc,
                          child: const RecordingTrackStatisticsPage(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      boxShadow: commonShadow,
                    ),
                    child: Icon(
                      Icons.bar_chart,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
