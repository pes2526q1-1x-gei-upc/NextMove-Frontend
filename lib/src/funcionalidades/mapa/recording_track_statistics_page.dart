import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';

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

          final recordedTrack = state.recordedTrack;
          if (recordedTrack == null || recordedTrack.points.isEmpty) {
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

          return _buildStatisticsView(context, recordedTrack, l10n, state.recordingElapsedTime);
        },
      ),
    );
  }

  Widget _buildStatisticsView(
    BuildContext context,
    RecordedTrack track,
    AppLocalizations l10n,
    Duration elapsedTime,
  ) {
    final duration = elapsedTime;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final durationString = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Main Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.straighten,
                  title: l10n.distance,
                  value: '${(track.totalDistanceMeters / 1000).toStringAsFixed(2)} km',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.access_time,
                  title: l10n.duration,
                  value: durationString,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.speed,
                  title: l10n.averageSpeed,
                  value: '${track.averageSpeedKmH.toStringAsFixed(1)} km/h',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.flash_on,
                  title: l10n.maxSpeed,
                  value: '${track.maxSpeedKmH.toStringAsFixed(1)} km/h',
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Elevation Statistics
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.terrain,
                        color: Colors.brown,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.elevation,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildElevationItem(
                          context,
                          icon: Icons.arrow_upward,
                          label: l10n.elevationGain,
                          value: '${track.elevationGainMeters.toStringAsFixed(1)} m',
                          color: Colors.green[700]!,
                        ),
                      ),
                      Expanded(
                        child: _buildElevationItem(
                          context,
                          icon: Icons.arrow_downward,
                          label: l10n.elevationLoss,
                          value: '${track.elevationLossMeters.toStringAsFixed(1)} m',
                          color: Colors.red[700]!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Environmental Impact
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.eco,
                        color: Colors.green,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.environmentalImpact,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImpactItem(
                          context,
                          icon: Icons.cloud_queue,
                          label: l10n.co2Saved,
                          value: '${track.co2SavedKG.toStringAsFixed(2)} kg',
                          color: Colors.blue[700]!,
                        ),
                      ),
                      Expanded(
                        child: _buildImpactItem(
                          context,
                          icon: Icons.local_fire_department,
                          label: l10n.caloriesBurned,
                          value: '${track.kcalBurned.toStringAsFixed(0)} kcal',
                          color: Colors.orange[700]!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Current Speed (if available)
          if (track.points.length > 1) ...[
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
          ],

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

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElevationItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildImpactItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}