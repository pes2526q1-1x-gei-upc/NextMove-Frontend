import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/enrolled_challenge.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/presentation/bloc/challenges_bloc.dart';
import 'package:eventide/eventide.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/presentation/widgets/challenge_progress_indicator.dart';
import 'package:nextmove_app/src/shared/utils.dart';
import 'package:url_launcher/url_launcher.dart';

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

    return BlocBuilder<ChallengesBloc, ChallengesState>(
      builder: (context, state) {
        Challenge displayChallenge = challenge;
        if (state is ChallengesLoaded) {
          if (state.enrolledChallenge?.id == challenge.id) {
            displayChallenge = state.enrolledChallenge!;
          } else {
            displayChallenge = state.challenges.firstWhere(
              (c) => c.id == challenge.id,
              orElse: () => challenge,
            );
          }
        }
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
                      TitleAndJoinButtonRow(
                        challenge: displayChallenge,
                        theme: theme,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        challenge.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (displayChallenge is EnrolledChallenge) ...[
                        sectionTitle(context, l10n.progress),
                        const SizedBox(height: 12),
                        ChallengeProgressIndicator(
                          enrolledChallenge: displayChallenge,
                          theme: theme,
                          l10n: l10n,
                        ),
                        const SizedBox(height: 24),
                      ],

                      infoRow(
                        context,
                        Icons.star,
                        l10n.points(challenge.points),
                        Icons.route,
                        "${challenge.distance.toStringAsFixed(1)} km",
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
      },
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
                if (challenge.company.logoUrl != null)
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(challenge.company.logoUrl!),
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
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: challenge.company.email!,
                        );
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                      child: Text(
                        challenge.company.email!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
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
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse(challenge.company.url!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      child: Text(
                        challenge.company.url!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
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
    final ChallengesBloc challengesBloc = context.read<ChallengesBloc>();
    final currentState = challengesBloc.state as ChallengesLoaded;
    final bool isEnrolledToAChallenge = currentState.hasEnrolledChallenge;
    final bool isThisChallengeEnrolled =
        currentState.enrolledChallenge?.id == challenge.id;
    final bool isThisChallengeCompleted = challenge.isCompleted;
    final bool isChallengeActive =
        challenge.startingDate.isBefore(DateTime.now()) &&
        challenge.endingDate.isAfter(DateTime.now());

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              challenge.name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        if (!isEnrolledToAChallenge ||
            ((isEnrolledToAChallenge && isThisChallengeEnrolled)) ||
            isThisChallengeCompleted) ...[
          ElevatedButton(
            onPressed:
                (isThisChallengeEnrolled ||
                    isThisChallengeCompleted ||
                    !isChallengeActive)
                ? null
                : () {
                    challengesBloc.add(EnrollInChallengeEvent(challenge.id));
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isThisChallengeEnrolled ||
                      isThisChallengeCompleted ||
                      !isChallengeActive
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.primary,
            ),
            child: Text(
              isThisChallengeEnrolled
                  ? l10n.enrolled
                  : isThisChallengeCompleted
                  ? l10n.completed
                  : isChallengeActive
                  ? l10n.enroll
                  : l10n.inactive,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    isThisChallengeEnrolled ||
                        isThisChallengeCompleted ||
                        !isChallengeActive
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        ElevatedButton(
          onPressed: () async {
            await addChallengeToCalendar(context, challenge);
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
          ),
          child: Icon(Icons.calendar_month),
        ),
      ],
    );
  }

  Future<void> addChallengeToCalendar(
    BuildContext context,
    Challenge challenge,
  ) async {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    try {
      await Eventide().createEventThroughNativePlatform(
        title: challenge.name,
        startDate: challenge.startingDate,
        endDate: challenge.endingDate,
        isAllDay: true,
        description: challenge.description,
        url: challenge.company.url,
      );
    } catch (e) {
      if (e is ETPresentationException || e is ETGenericException) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.errorAddingToCalendar}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
