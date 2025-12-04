import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/recording_track_statistics_page.dart';

class RecordTrackWidget extends StatelessWidget {
  const RecordTrackWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is! MapLoadedState) {
          return const SizedBox.shrink();
        }

        final isRecording = state.isRecordingRoute;

        if (isRecording) {
          // When recording, show both stop button and statistics button
          return Positioned(
            bottom: 30,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Statistics button
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.bar_chart,
                      color: theme.colorScheme.onSecondaryContainer,
                      size: 24,
                    ),
                  ),
                ),
                // Stop recording button
                GestureDetector(
                  onTap: () {
                    final bloc = context.read<MapBloc>();
                    bloc.add(const StopRouteRecordingEvent());
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.stop,
                      color: theme.colorScheme.onError,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // When not recording, show only the start button
          return Positioned(
            bottom: 30,
            right: 16,
            child: GestureDetector(
              onTap: () {
                final bloc = context.read<MapBloc>();
                bloc.add(const StartRouteRecordingEvent());
              },
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: theme.colorScheme.onPrimary,
                  size: 32,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
