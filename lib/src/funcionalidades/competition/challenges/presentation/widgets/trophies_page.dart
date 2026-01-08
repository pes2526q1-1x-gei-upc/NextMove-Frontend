import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/presentation/widgets/trophy_card.dart';

class TrophiesPage extends StatelessWidget {
  final List<Challenge> challenges;

  const TrophiesPage({super.key, required this.challenges});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trophies)),
      body: challenges.isEmpty
          ? Column(
              children: [
                Expanded(
                  child: Center(child: Text(l10n.noChallengesAvailable)),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    l10n.trophyAttribution,
                    style: const TextStyle(fontSize: 10.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.8,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final challenge = challenges[index];
                      return TrophyCard(challenge: challenge);
                    }, childCount: challenges.length),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      l10n.trophyAttribution,
                      style: const TextStyle(fontSize: 10.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
