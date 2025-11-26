import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_event.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_state.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/data/repositories/assessment_repository.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/widgets/review_card_widget.dart';

class StationReviewsPage extends StatelessWidget {
  final String stationName;
  final String stationId; 
  final Color themeColor;

  const StationReviewsPage({
    super.key,
    required this.stationName,
    required this.stationId, 
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => AssessmentBloc(
        assessmentRepository: AssessmentRepository(),
      )..add(GetAssessmentsByStationEvent(stationId: stationId)),
      
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: AppBar(
          title: Text(
            l10n.opinions, 
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<AssessmentBloc, AssessmentState>(
          builder: (context, state) {
            // --- ESTADO CARGANDO ---
            if (state.status == AssessmentStatus.loading) {
              return Center(
                child: CircularProgressIndicator(color: themeColor),
              );
            }
            
            // --- ESTADO ERROR ---
            if (state.status == AssessmentStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? l10n.errorLoadingReviews,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                      onPressed: () {
                        context.read<AssessmentBloc>().add(
                              GetAssessmentsByStationEvent(stationId: stationId),
                            );
                      },
                      child: Text(l10n.retry), 
                    )
                  ],
                ),
              );
            }

            // --- ESTADO ÉXITO ---
            if (state.status == AssessmentStatus.success) {
              final reviews = state.assessments;
              debugPrint("id de la station $stationId");
              if (reviews.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        l10n.withoutOpinions, 
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.firstToReview, 
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                );
              }

              // LISTA DE OPINIONES
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  
                  return ReviewCard(
                    userName: review.nickname,
                    date: _formatDate(review.created_at),
                    rating: review.score,
                    comment: review.description,
                    themeColor: themeColor,
                  );
                },
              );
            }

            // Estado inicial por defecto
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}