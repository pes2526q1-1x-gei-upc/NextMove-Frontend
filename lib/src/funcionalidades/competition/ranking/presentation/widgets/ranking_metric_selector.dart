import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class RankingMetricSelector extends StatelessWidget {
  final String? selectedMetric;
  final ValueChanged<String?> onMetricChanged;

  const RankingMetricSelector({
    super.key,
    required this.selectedMetric,
    required this.onMetricChanged,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;

    List<Map<String, String>> metrics = [
      {'key': 'calorias_quemadas', 'label': l10n.caloriesBurned},
      {'key': 'km_recorridos', 'label': l10n.distance},
      {'key': 'num_rutas', 'label': l10n.numberOfRoutes},
      {'key': 'elevacion_positiva', 'label': l10n.elevationGain},
      {'key': 'co2_ahorrado', 'label': l10n.co2Saved},
      {'key': 'num_retos_participados', 'label': l10n.challengesParticipated},
      {'key': 'num_retos_completados', 'label': l10n.challengesCompleted},
      {'key': 'puntos_totales', 'label': l10n.totalPoints},
    ];

    List<DropdownMenuItem<String>> metricsDropdownItems = metrics
        .map(
          (metric) => DropdownMenuItem<String>(
            value: metric['key'],
            child: Text(
              metric['label']!,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        )
        .toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      child: DropdownButton<String>(
        value: selectedMetric,
        items: metricsDropdownItems,
        onChanged: onMetricChanged,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: theme.colorScheme.primary,
        ),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: theme.cardColor,
      ),
    );
  }
}
