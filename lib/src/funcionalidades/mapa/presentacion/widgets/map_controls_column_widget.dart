import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
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
        final bottomOffset = 30.0;
        
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
                    margin: const EdgeInsets.only(bottom: 10),
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

              // Play/Stop recording button (only in bicycle mode)
              if (state.currentMode == StationType.bicycle) ...[
                GestureDetector(
                  onTap: () {
                    final bloc = context.read<MapBloc>();
                    if (state.isRecordingRoute) {
                      final l10n = AppLocalizations.of(context)!;
                      bloc.add(StopRouteRecordingEvent(l10n));
                    } else {
                      bloc.add(const StartRouteRecordingEvent());
                    }
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: state.isRecordingRoute
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.red.shade700
                              : Theme.of(context).colorScheme.error)
                          : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.green.shade700
                              : Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: commonShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.isRecordingRoute ? Icons.stop : Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            final text = state.isRecordingRoute 
                                ? l10n.stopRecording
                                : l10n.startRoute;
                            final words = text.split(' ');
                            
                            if (words.length == 1) {
                              return Text(
                                text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                ),
                              );
                            } else {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    words[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.0,
                                    ),
                                  ),
                                  Text(
                                    words.skip(1).join(' '),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
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
