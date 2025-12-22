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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
          color: Theme.of(context).colorScheme.primary,
        ),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
