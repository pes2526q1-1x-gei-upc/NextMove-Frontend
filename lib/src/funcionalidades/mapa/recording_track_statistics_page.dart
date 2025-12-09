import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/presentacion/widgets/statistics_widget.dart';

class RecordingTrackStatisticsPage extends StatelessWidget {
  const RecordingTrackStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.routeStatistics),
      ),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is! MapLoadedState) {
            return const Center(child: CircularProgressIndicator());
          }

          final recordingTrack = state.recordingTrack;
          if (recordingTrack == null || recordingTrack.points.isEmpty) {
            return Center(
              child: Text(
                l10n.noRouteDataAvailable,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            );
          }

          if (kDebugMode) {
            print('Statistics page - Elapsed time: ${state.recordingElapsedTime.inSeconds} seconds');
          }

          return _buildStatisticsView(context, recordingTrack, l10n, state.recordingElapsedTime);
        },
      ),
    );
  }

  Widget _buildStatisticsView(
    BuildContext context,
    RecordingTrack track,
    AppLocalizations l10n,
    Duration elapsedTime,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          StatisticsWidget(track: track, elapsedTime: elapsedTime, l10n: l10n),

          const SizedBox(height: 24),

          // Current Speed 
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.speed,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${l10n.currentSpeed}: ${track.points.last.speed.toStringAsFixed(1)} km/h',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

          // Stop Recording Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<MapBloc>().add(const StopRouteRecordingEvent());
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.stop),
              label: Text(l10n.stopRecording),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}