import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/ranking/domain/ranking_entry.dart';

class RankingUserList extends StatelessWidget {
  const RankingUserList({
    super.key,
    required this.selectedMetric,
    required this.rankingData,
  });

  final String? selectedMetric;
  final List<RankingEntry> rankingData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rankingData.length,
      itemBuilder: (context, index) {
        final entry = rankingData[index];
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }
}
