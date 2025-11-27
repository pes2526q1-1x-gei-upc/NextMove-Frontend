import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_event.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_state.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/widgets/review_card_widget.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/pages/rate_station_bottom_sheet_widget.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_entity.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(
          l10n.opinions, 
          style: const TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold, 
            fontSize: 20
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
          // --- LOADING ---
          if (state.status == AssessmentStatus.loading) {
            return Center(child: CircularProgressIndicator(color: themeColor));
          }
          
          // --- FAILURE ---
          if (state.status == AssessmentStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? l10n.error),
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

          // --- SUCCESS ---
          if (state.status == AssessmentStatus.success) {
            final reviews = state.assessments;

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

            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final review = reviews[index];

                // WIDGET INTELIGENTE DE PROPIEDAD
                return _AsyncReviewItem(
                  review: review,
                  themeColor: themeColor,
                  stationId: stationId,
                  stationName: stationName,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// --- WIDGET AUXILIAR PARA VERIFICAR PROPIEDAD ASÍNCRONAMENTE ---
class _AsyncReviewItem extends StatefulWidget {
  final AssessmentEntity review;
  final Color themeColor;
  final String stationId;
  final String stationName;

  const _AsyncReviewItem({
    required this.review,
    required this.themeColor,
    required this.stationId,
    required this.stationName,
  });

  @override
  State<_AsyncReviewItem> createState() => _AsyncReviewItemState();
}

class _AsyncReviewItemState extends State<_AsyncReviewItem> {
  bool _isMine = false;
  bool _isLoadingOwnership = true;

  @override
  void initState() {
    super.initState();
    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      if (mounted) setState(() => _isLoadingOwnership = false);
      return;
    }

    if (widget.review.nickname == currentUser.displayName) {
       if (mounted) setState(() { _isMine = true; });
    }

    try {
      final repo = context.read<AssessmentBloc>().assessmentRepository;
      final emailFromBackend = await repo.getUserEmailByNickname(widget.review.nickname);

      if (mounted) {
        setState(() {
          _isMine = (emailFromBackend != null && emailFromBackend == currentUser.email);
          _isLoadingOwnership = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingOwnership = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Solo permitimos editar si la carga terminó y es mío
    final canEdit = !_isLoadingOwnership && _isMine;

    return ReviewCard(
      userName: widget.review.nickname,
      date: "${widget.review.created_at.day}/${widget.review.created_at.month}/${widget.review.created_at.year}",
      rating: widget.review.score.toDouble(),
      comment: widget.review.description,
      themeColor: widget.themeColor,
      
      // Si canEdit es true, pasamos la función para abrir el modal
      onEditPressed: canEdit ? () {
          final assessmentBloc = context.read<AssessmentBloc>();
          
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => BlocProvider.value(
              value: assessmentBloc,
              child: RateStationBottomSheet(
                stationId: widget.stationId,
                stationName: widget.stationName,
                themeColor: widget.themeColor,
                existingAssessment: widget.review,
              ),
            ),
          );
      } : null,
    );
  }
}