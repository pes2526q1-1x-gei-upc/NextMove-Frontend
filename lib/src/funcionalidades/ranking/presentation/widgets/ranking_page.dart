import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/ranking/domain/ranking_entry.dart';
import 'package:nextmove_app/src/funcionalidades/ranking/presentation/bloc/ranking_bloc.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  String? selectedMetric;
  late RankingBloc _rankingBloc;

  @override
  void initState() {
    super.initState();
    selectedMetric = "calorias_quemadas";
    _rankingBloc = RankingBloc()..add(LoadRankingEvent(selectedMetric!));
  }

  @override
  void dispose() {
    _rankingBloc.close();
    super.dispose();
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

    return BlocProvider.value(
      value: _rankingBloc,
      child: BlocListener<RankingBloc, RankingState>(
        listener: (context, state) {
          if (state is RankingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<RankingBloc, RankingState>(
          builder: (context, state) {
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
                      context.read<RankingBloc>().add(LoadRankingEvent(value!));
                    },
                  ),
                  if (state is RankingLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (state is RankingLoaded)
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.rankingData.length,
                        itemBuilder: (context, index) {
                          final entry = state.rankingData[index];
                          return ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent,
                              ),
                              width: 40,
                              height: 40,
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                ),
                              ),
                            ),
                            title: Text(entry.email),
                            subtitle: Text(
                              selectedMetric == 'calorias_quemadas'
                                  ? '${entry.caloriesBurned ?? 0} kcal'
                                  : selectedMetric == 'km_recorridos'
                                  ? '${entry.distance ?? 0} km'
                                  : selectedMetric == 'num_rutas'
                                  ? '${entry.numberOfRoutes ?? 0}'
                                  : '${entry.elevationGain ?? 0} m',
                            ),
                          );
                        },
                      ),
                    )
                  else if (state is RankingError)
                    Center(child: Text('Error: ${state.message}')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
