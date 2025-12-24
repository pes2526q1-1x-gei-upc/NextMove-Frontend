import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Text startDate = Text(
      '${challenge.startingDate.day.toString().padLeft(2, '0')}/${challenge.startingDate.month.toString().padLeft(2, '0')}/${challenge.startingDate.year}',
    );
    Text endDate = Text(
      '${challenge.endingDate.day.toString().padLeft(2, '0')}/${challenge.endingDate.month.toString().padLeft(2, '0')}/${challenge.endingDate.year}',
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star),
                const SizedBox(width: 8),
                Text(l10n.points(challenge.points)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                startDate,
                const SizedBox(width: 8),
                Text('—'),
                const SizedBox(width: 8),
                endDate,
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.route),
                const SizedBox(width: 8),
                Text("${challenge.distance.toInt()} km"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
