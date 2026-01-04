import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/shared/domain/track_statistics.dart';

class StatisticsWidget extends StatelessWidget {
  const StatisticsWidget({
    super.key,
    required this.track,
    required this.elapsedTime,
    required this.l10n,
  });

  final TrackStatistics track;
  final Duration elapsedTime;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final duration = elapsedTime;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final durationString = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.straighten,
                title: l10n.distance,
                value: '${(track.totalDistanceMeters / 1000).toStringAsFixed(2)} km',
                color: Colors.blue,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.access_time,
                title: l10n.duration,
                value: durationString,
                color: Colors.purple,
                isDark: isDark,
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
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.flash_on,
                title: l10n.maxSpeed,
                value: '${track.maxSpeedKmH.toStringAsFixed(1)} km/h',
                color: Colors.red,
                isDark: isDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Elevation Statistics
        _buildSectionCard(
          context,
          icon: Icons.terrain,
          iconColor: Colors.brown,
          title: l10n.elevation,
          isDark: isDark,
          child: Row(
            children: [
              Expanded(
                child: _buildElevationItem(
                  context,
                  icon: Icons.trending_up,
                  label: l10n.elevationGain,
                  value: '${track.elevationGainMeters.toStringAsFixed(1)} m',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildElevationItem(
                  context,
                  icon: Icons.trending_down,
                  label: l10n.elevationLoss,
                  value: '${track.elevationLossMeters.toStringAsFixed(1)} m',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Environmental Impact
        _buildSectionCard(
          context,
          icon: Icons.eco,
          iconColor: Colors.green,
          title: l10n.environmentalImpact,
          isDark: isDark,
          child: Row(
            children: [
              Expanded(
                child: _buildImpactItem(
                  context,
                  icon: Icons.cloud_queue,
                  label: l10n.co2Saved,
                  value: '${track.co2SavedKG.toStringAsFixed(2)} kg',
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildImpactItem(
                  context,
                  icon: Icons.local_fire_department,
                  label: l10n.caloriesBurned,
                  value: '${track.kcalBurned.toStringAsFixed(0)} kcal',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final iconBgColor = color.withValues(alpha: isDark ? 0.2 : 0.1);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final iconBgColor = iconColor.withValues(alpha: isDark ? 0.2 : 0.1);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
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
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
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
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}