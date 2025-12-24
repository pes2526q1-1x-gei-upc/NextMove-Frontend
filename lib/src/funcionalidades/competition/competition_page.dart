import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/presentation/widgets/challenges_page.dart';
import 'package:nextmove_app/src/funcionalidades/competition/ranking/presentation/widgets/ranking_page.dart';

class CompetitionPage extends StatelessWidget {
  const CompetitionPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.competition),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.leaderboard), text: l10n.ranking),
              Tab(icon: Icon(Icons.workspace_premium), text: l10n.challenges),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: const TabBarView(
            children: <Widget>[
              Center(child: RankingPage()),
              Center(child: ChallengesPage()),
            ],
          ),
        ),
      ),
    );
  }
}
