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
    ];

    List<DropdownMenuItem<String>> metricsDropdownItems = metrics
        .map(
          (metric) => DropdownMenuItem<String>(
            value: metric['key'],
            child: Text(metric['label']!),
          ),
        )
        .toList();

    return DropdownButton<String>(
      value: selectedMetric,
      items: metricsDropdownItems,
      onChanged: onMetricChanged,
    );
  }
}
