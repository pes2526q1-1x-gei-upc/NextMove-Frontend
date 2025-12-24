import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/presentation/bloc/challenges_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/presentation/challenge_card.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: BlocProvider(
        create: (context) => ChallengesBloc()..add(const LoadChallengesEvent()),
        child: BlocBuilder<ChallengesBloc, ChallengesState>(
          builder: (context, state) {
            if (state is ChallengesLoading || state is ChallengesInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChallengesLoaded) {
              if (state.challenges.isEmpty) {
                return Center(child: Text(l10n.noChallengesAvailable));
              }
              return ListView.builder(
                itemCount: state.challenges.length,
                itemBuilder: (context, index) {
                  final challenge = state.challenges[index];
                  return ChallengeCard(challenge: challenge);
                },
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
