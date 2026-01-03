import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/enrolled_challenge.dart';

class ChallengeProgressIndicator extends StatelessWidget {
  const ChallengeProgressIndicator({
    super.key,
    required this.enrolledChallenge,
    required this.theme,
    required this.l10n,
  });

  final EnrolledChallenge enrolledChallenge;
  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final progressPercentage = enrolledChallenge.completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progressPercentage / 100,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
        const SizedBox(height: 4),
        Text(
          '${enrolledChallenge.currentDistance.toStringAsFixed(1)} / ${enrolledChallenge.totalDistance.toStringAsFixed(1)} km ($progressPercentage%)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
