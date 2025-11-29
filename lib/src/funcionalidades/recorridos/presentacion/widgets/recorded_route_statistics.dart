import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class RecordedRouteStatistics extends StatelessWidget {
  final RecordedRoute track;

  const RecordedRouteStatistics({super.key, 
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final duration = track.startTime!.difference(track.endTime!).abs();
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final durationString = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
    color: Colors.white,
    child: SingleChildScrollView(
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
                  value: '${(track.distance / 1000).toStringAsFixed(2)} km',
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
                  value: '${track.averageSpeed!.toStringAsFixed(1)} km/h',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.flash_on,
                  title: l10n.maxSpeed,
                  value: '${track.maxSpeed!.toStringAsFixed(1)} km/h',
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
                          value: '${track.elevationGain!.toStringAsFixed(1)} m',
                          color: Colors.green[700]!,
                        ),
                      ),
                      Expanded(
                        child: _buildElevationItem(
                          context,
                          icon: Icons.arrow_downward,
                          label: l10n.elevationLoss,
                          value: '${track.elevationLoss!.toStringAsFixed(1)} m',
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
                          value: '${track.co2!.toStringAsFixed(2)} kg',
                          color: Colors.blue[700]!,
                        ),
                      ),
                      Expanded(
                        child: _buildImpactItem(
                          context,
                          icon: Icons.local_fire_department,
                          label: l10n.caloriesBurned,
                          value: '${track.kcal!.toStringAsFixed(0)} kcal',
                          color: Colors.orange[700]!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
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
