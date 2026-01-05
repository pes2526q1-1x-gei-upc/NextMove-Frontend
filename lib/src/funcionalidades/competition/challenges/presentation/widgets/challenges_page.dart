import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/presentation/bloc/challenges_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/presentation/widgets/challenge_card.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/presentation/widgets/trophies_page.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  late final ChallengesBloc _challengesBloc;

  @override
  void initState() {
    super.initState();
    _challengesBloc = ChallengesBloc()..add(const LoadChallengeListEvent());
  }

  @override
  void dispose() {
    _challengesBloc.close();
    super.dispose();
  }

  Future<void> _refreshChallenges() async {
    _challengesBloc.add(const LoadChallengeListEvent());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: BlocProvider<ChallengesBloc>.value(
        value: _challengesBloc,
        child: BlocBuilder<ChallengesBloc, ChallengesState>(
          builder: (context, state) {
            if (state is ChallengesLoading || state is ChallengesInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChallengesLoaded) {
              if (state.challenges.isEmpty) {
                return Center(child: Text(l10n.noChallengesAvailable));
              }
              return Column(
                children: [
                  TrophiesButton(l10n: l10n, state: state),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshChallenges,
                      child: ListView.builder(
                        itemCount: state.challenges.length,
                        itemBuilder: (context, index) {
                          final challenge = state.challenges[index];
                          return ChallengeCard(challenge: challenge);
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is ChallengesError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return Center(child: Text(l10n.unknownState));
          },
        ),
      ),
    );
  }
}

class TrophiesButton extends StatelessWidget {
  const TrophiesButton({super.key, required this.l10n, required this.state});

  final AppLocalizations l10n;
  final ChallengesLoaded state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
      child: Row(
        children: [
          Expanded(
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return TrophiesPage(challenges: state.challenges);
                    },
                  ),
                );
              },
              label: Text(l10n.trophies),
              icon: const Icon(Icons.emoji_events),
            ),
          ),
        ],
      ),
    );
  }
}
