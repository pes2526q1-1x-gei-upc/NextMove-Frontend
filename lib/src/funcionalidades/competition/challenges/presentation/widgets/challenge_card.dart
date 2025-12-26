import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/presentation/widgets/challenge_details_page.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/presentation/widgets/utils.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    Text startDate = Text(
      formatDate(challenge.startingDate),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
      ),
    );
    Text endDate = Text(
      formatDate(challenge.endingDate),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
      ),
    );

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChallengeDetailsPage(challenge: challenge),
          ),
        );
      },
      child: Card(
        elevation: 6.0,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: theme.colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Photo(challenge: challenge, theme: theme),
                Text(
                  challenge.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  challenge.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                PointsAndDistanceRow(
                  l10n: l10n,
                  challenge: challenge,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                StartAndFinishDates(
                  theme: theme,
                  startDate: startDate,
                  endDate: endDate,
                ),
                const SizedBox(height: 12),
                CompanyNameAndLogoRow(challenge: challenge, theme: theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompanyNameAndLogoRow extends StatelessWidget {
  const CompanyNameAndLogoRow({
    super.key,
    required this.challenge,
    required this.theme,
  });

  final Challenge challenge;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final double companyLogoSize = 24;
    return Row(
      children: [
        challenge.company.logo != null
            ? Image.network(
                challenge.company.logo!,
                width: companyLogoSize,
                height: companyLogoSize,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.business,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: companyLogoSize,
                  );
                },
              )
            : Icon(
                Icons.business,
                color: theme.colorScheme.onSurfaceVariant,
                size: companyLogoSize,
              ),
        const SizedBox(width: 8),
        Text(
          challenge.company.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class StartAndFinishDates extends StatelessWidget {
  const StartAndFinishDates({
    super.key,
    required this.theme,
    required this.startDate,
    required this.endDate,
  });

  final ThemeData theme;
  final Text startDate;
  final Text endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          startDate,
          const SizedBox(width: 8),
          Text(
            '—',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          endDate,
        ],
      ),
    );
  }
}

class PointsAndDistanceRow extends StatelessWidget {
  const PointsAndDistanceRow({
    super.key,
    required this.l10n,
    required this.challenge,
    required this.theme,
  });

  final AppLocalizations l10n;
  final Challenge challenge;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star, size: 20),
        const SizedBox(width: 8),
        Text(
          l10n.points(challenge.points),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 24),
        Icon(Icons.route, size: 20),
        const SizedBox(width: 8),
        Text(
          "${challenge.distance.toInt()} km",
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class Photo extends StatelessWidget {
  const Photo({super.key, required this.challenge, required this.theme});

  final Challenge challenge;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final double imageHeight = 150;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Center(
        child: challenge.photo != null
            ? Image.network(
                challenge.photo!,
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 100,
                  );
                },
              )
            : SizedBox(
                height: imageHeight,
                child: Icon(
                  Icons.workspace_premium,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
      ),
    );
  }
}
