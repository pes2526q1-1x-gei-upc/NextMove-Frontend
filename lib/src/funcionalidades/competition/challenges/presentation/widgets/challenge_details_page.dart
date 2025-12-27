import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/presentation/widgets/utils.dart';

class ChallengeDetailsPage extends StatelessWidget {
  const ChallengeDetailsPage({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final startDate = Text(
      formatDate(challenge.startingDate),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
    final endDate = Text(
      formatDate(challenge.endingDate),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
    final double photoHeight = 300;

    return Scaffold(
      appBar: AppBar(title: Text(challenge.name), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (challenge.photo != null)
              SizedBox(
                height: photoHeight,
                width: double.infinity,
                child: Image.network(
                  challenge.photo!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: photoHeight,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: photoHeight,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.workspace_premium,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleAndJoinButtonRow(challenge: challenge, theme: theme),
                  const SizedBox(height: 16),

                  Text(
                    challenge.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  infoRow(
                    context,
                    Icons.star,
                    l10n.points(challenge.points),
                    Icons.route,
                    "${challenge.distance.toInt()} km",
                  ),
                  const SizedBox(height: 24),

                  sectionTitle(context, l10n.dates),
                  const SizedBox(height: 12),
                  dateRow(context, l10n.startDate, startDate),
                  const SizedBox(height: 8),
                  dateRow(context, l10n.endDate, endDate),
                  const SizedBox(height: 24),

                  sectionTitle(context, l10n.company),
                  const SizedBox(height: 12),
                  companySection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(
    BuildContext context,
    IconData icon1,
    String text1,
    IconData icon2,
    String text2,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon1, size: 24, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          text1,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 32),
        Icon(icon2, size: 24, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          text2,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget dateRow(BuildContext context, String label, Text dateText) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        dateText,
      ],
    );
  }

  Widget companySection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (challenge.company.logo != null)
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(challenge.company.logo!),
                    onBackgroundImageError: (_, __) =>
                        const Icon(Icons.business),
                  )
                else
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.business,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    challenge.company.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (challenge.company.description != null) ...[
              const SizedBox(height: 12),
              Text(
                challenge.company.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                ),
              ),
            ],
            if (challenge.company.email != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    challenge.company.email!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
            if (challenge.company.url != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    challenge.company.url!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TitleAndJoinButtonRow extends StatelessWidget {
  const TitleAndJoinButtonRow({
    super.key,
    required this.challenge,
    required this.theme,
  });

  final Challenge challenge;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Text(
            challenge.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Action for enroll button
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: challenge.isEnrolled
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.primary,
          ),
          child: Text(
            challenge.isEnrolled ? l10n.enrolled : l10n.enroll,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: challenge.isEnrolled
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}