import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/pages/station_assessments_page.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/utils/create_star_rating_row.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_event.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_state.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_entity.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/pages/rate_station_bottom_sheet_widget.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';

class StationHeaderWidget extends StatelessWidget {
  final StationDetails station;
  final Color themeColor;

  const StationHeaderWidget({
    super.key,
    required this.station,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final assessmentState = context.watch<AssessmentBloc>().state;

    double? displayRating;

    if (assessmentState.totalAssessments > 0) {
      displayRating = assessmentState.averageScore;
    } else if (assessmentState.status == AssessmentStatus.success) {
      displayRating = null;
    } else {
      displayRating = station.rating;
    }

    // Use the userHasAssessed field from state
    final bool userHasAssessed = assessmentState.userHasAssessed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- NOMBRE DE LA ESTACIÓN ---
        Text(
          station.name ?? l10n.unknown,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        // --- DIRECCIÓN ---
        Row(
          children: [
            Icon(Icons.location_on_rounded, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                station.address ?? l10n.unknown,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // --- BARRA DE ACCIONES (Estrellas | Link | Botón) ---
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            // ESTRELLAS (Si existen)
            if (displayRating != null) ...[
              createStarRatingRow((displayRating * 2).round()),
              Text(
                '(${displayRating.toStringAsFixed(1)})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),

              // Separador vertical
              Container(width: 1, height: 16, color: Colors.grey[300]),

              // Link "Ver opiniones"
              InkWell(
                onTap: () => _navigateToReviews(context, l10n),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Text(
                    "${l10n.seeOpinions} (${assessmentState.totalAssessments})",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ] else
              // TEXTO "SIN OPINIONES" (Si no hay estrellas)
              InkWell(
                onTap: () => _navigateToReviews(context, l10n),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    l10n.withoutOpinions,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

            // BOTÓN DE ACCIÓN (VALORAR O EDITAR)
            InkWell(
              onTap: () async {
                final assessmentBloc = context.read<AssessmentBloc>();

                debugPrint("=== EDIT BUTTON CLICKED ===");
                debugPrint("userHasAssessed: $userHasAssessed");
                debugPrint(
                  "Current assessments count: ${assessmentState.assessments.length}",
                );

                // If user has assessed but we don't have the assessments loaded yet, fetch them first
                if (userHasAssessed && assessmentState.assessments.isEmpty) {
                  debugPrint(
                    "Fetching assessments for station ${station.id}...",
                  );
                  assessmentBloc.add(
                    GetAssessmentsByStationEvent(
                      stationId: station.id.toString(),
                    ),
                  );

                  // Wait a bit for the assessments to load
                  await Future.delayed(const Duration(milliseconds: 800));
                }

                // Get the updated state after potential fetch
                final currentState = assessmentBloc.state;
                debugPrint(
                  "After fetch - assessments count: ${currentState.assessments.length}",
                );

                AssessmentEntity? existingReview;

                if (userHasAssessed && currentState.assessments.isNotEmpty) {
                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    // Try to get nickname from UserProvider first, fallback to Firebase displayName
                    final userProvider = context.read<UserProvider>();
                    final userNickname =
                        userProvider.user?['nickname'] as String? ??
                        currentUser.displayName;

                    debugPrint("Looking for assessment by user: $userNickname");
                    debugPrint(
                      "Available assessments: ${currentState.assessments.map((a) => a.nickname).toList()}",
                    );

                    try {
                      existingReview = currentState.assessments.firstWhere(
                        (review) => review.nickname == userNickname,
                      );
                      debugPrint(
                        "Found existing review with score: ${existingReview.score}",
                      );
                    } catch (e) {
                      debugPrint(
                        "No matching review found for user: $userNickname",
                      );
                      existingReview = null;
                    }
                  }
                }

                debugPrint(
                  "existingReview is ${existingReview != null ? 'NOT NULL' : 'NULL'}",
                );
                debugPrint("=========================");

                if (!context.mounted) return;

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => BlocProvider.value(
                    value: assessmentBloc,
                    child: RateStationBottomSheet(
                      stationId: station.id.toString(),
                      stationName: station.name ?? l10n.station,
                      themeColor: themeColor,
                      // Pass existing review to activate edit mode
                      existingAssessment: existingReview,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: themeColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon changes based on whether user has assessed
                    Icon(
                      userHasAssessed
                          ? Icons.edit_rounded
                          : Icons.star_rate_rounded,
                      size: 14,
                      color: themeColor,
                    ),
                    const SizedBox(width: 4),
                    // Text changes based on whether user has assessed
                    Text(
                      userHasAssessed ? l10n.editReview : l10n.rate,
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToReviews(BuildContext context, AppLocalizations l10n) {
    final assessmentBloc = context.read<AssessmentBloc>();
    assessmentBloc.add(
      GetAssessmentsByStationEvent(stationId: station.id.toString()),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: assessmentBloc,
          child: StationReviewsPage(
            stationId: station.id.toString(),
            stationName: station.name ?? l10n.station,
            themeColor: themeColor,
          ),
        ),
      ),
    );
  }
}
