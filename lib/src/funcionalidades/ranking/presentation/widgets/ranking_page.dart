import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  String? selectedMetric;

  @override
  void initState() {
    super.initState();
    selectedMetric = "calorias_quemadas";
  }

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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ranking)),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedMetric,
            items: metricsDropdownItems,
            onChanged: (value) {
              setState(() {
                selectedMetric = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
