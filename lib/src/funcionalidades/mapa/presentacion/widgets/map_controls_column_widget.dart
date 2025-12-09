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

  const MapControlsColumnWidget({
    super.key,
    this.userLocation,
    this.mapController,
    required this.currentMapType,
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

        return Positioned(
          bottom: 30,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Satellite/Map toggle button
              GestureDetector(
                onTap: () =>
                    context.read<MapBloc>().add(const ToggleMapTypeEvent()),
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
                  margin: const EdgeInsets.only(bottom: 10),
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
                      color: theme.colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: commonShadow,
                    ),
                    child: Icon(
                      Icons.bar_chart,
                      color: theme.colorScheme.onSecondaryContainer,
                      size: 24,
                    ),
                  ),
                ),
              ],

              // Record/Stop button (only in bicycle mode)
              if (state.currentMode == StationType.bicycle) ...[
                GestureDetector(
                  onTap: () {
                    final bloc = context.read<MapBloc>();
                    if (isRecording) {
                      bloc.add(const StopRouteRecordingEvent());
                    } else {
                      bloc.add(const StartRouteRecordingEvent());
                    }
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: isRecording
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.55 : 0.25,
                          ),
                          spreadRadius: 1,
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      isRecording ? Icons.stop : Icons.play_arrow,
                      color: isRecording
                          ? theme.colorScheme.onError
                          : theme.colorScheme.onPrimary,
                      size: 32,
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
