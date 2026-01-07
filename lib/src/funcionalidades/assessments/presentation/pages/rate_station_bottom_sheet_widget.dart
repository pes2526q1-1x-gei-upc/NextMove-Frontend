import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_event.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_state.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_entity.dart';
import 'package:nextmove_app/src/core/services/bad_words_service.dart';

class RateStationBottomSheet extends StatefulWidget {
  final String stationId;
  final String stationName;
  final Color themeColor;
  final AssessmentEntity? existingAssessment;

  const RateStationBottomSheet({
    super.key,
    required this.stationId,
    required this.stationName,
    required this.themeColor,
    this.existingAssessment,
  });

  @override
  State<RateStationBottomSheet> createState() => _RateStationBottomSheetState();
}

class _RateStationBottomSheetState extends State<RateStationBottomSheet> {
  int _selectedScore = 0;
  late TextEditingController _commentController;
  bool _isSubmitting = false;
  bool _pendingOperation = false;
  String? _errorMessage;
  final BadWordsService _badWordsService = BadWordsService();

  @override
  void initState() {
    super.initState();
    if (widget.existingAssessment != null) {
      _selectedScore = widget.existingAssessment!.score;
      _commentController = TextEditingController(text: widget.existingAssessment!.description);
    } else {
      _commentController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Helper para textos de estrellas
  String _getRatingLabel(int score, AppLocalizations l10n) {
    switch (score) {
      case 1: return l10n.bad;     
      case 2: return l10n.regular;
      case 3: return l10n.good;
      case 4: return l10n.veryGood;
      case 5: return l10n.excellent;
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.existingAssessment != null;

    return BlocListener<AssessmentBloc, AssessmentState>(
      listenWhen: (previous, current) {
        // Solo escuchar cuando tenemos una operación pendiente y hay un cambio de estado relevante
        if (!_pendingOperation) return false;
        
        // Escuchar cuando cambia de loading a success o failure
        if (previous.status == AssessmentStatus.loading && 
            (current.status == AssessmentStatus.success || current.status == AssessmentStatus.failure)) {
          return true;
        }
        
        return false;
      },
      listener: (context, state) {
        if (!_pendingOperation) return;
        
        if (state.status == AssessmentStatus.failure) {
          setState(() {
            _isSubmitting = false;
            _pendingOperation = false;
            _errorMessage = state.errorMessage;
          });
        } else if (state.status == AssessmentStatus.success && _isSubmitting) {
          // Solo cerrar si acabamos de recibir éxito después de una operación pendiente
          setState(() {
            _isSubmitting = false;
            _pendingOperation = false;
            _errorMessage = null;
          });
          Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing 
                ? l10n.updatedReview
                : l10n.thankYouForYourReview),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Drag Handle ---
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- HEADER CON BOTÓN ELIMINAR (Solo en edición) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isEditing) const SizedBox(width: 48), 
              Text(
                isEditing ? l10n.editReview : l10n.reviewStation, 
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  tooltip: l10n.delete,
                  onPressed: () {
                    // DIÁLOGO DE CONFIRMACIÓN
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.delete),
                        content: Text(l10n.sureActionConfirmation),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx), 
                            child: Text(
                              l10n.cancel, 
                              style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.6))
                            )
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx); 
                              context.read<AssessmentBloc>().add(
                                DeleteAssessmentEvent(stationId: widget.stationId)
                              );
                              
                              Navigator.pop(context); 
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.deletedReview)),
                              );
                            },
                            child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                )
              else
                const SizedBox(width: 0),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            widget.stationName,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6), 
              fontSize: 14
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          // --- SELECTOR DE ESTRELLAS ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedScore = starIndex;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    starIndex <= _selectedScore
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: starIndex <= _selectedScore
                        ? Colors.amber
                        : theme.colorScheme.onSurface.withOpacity(0.3),
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            _getRatingLabel(_selectedScore, l10n),
            style: TextStyle(
              color: _selectedScore > 0 ? Colors.amber[800] : Colors.transparent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 30),

          // --- CAMPO DE COMENTARIOS ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor, 
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _commentController,
                  maxLines: 3,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: l10n.writeYourOpinion, 
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    errorText: null,
                    errorBorder: InputBorder.none,
                    errorStyle: const TextStyle(height: 0),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // --- BOTÓN DE ACCIÓN (CREAR O ACTUALIZAR) ---
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: widget.themeColor.withValues(alpha: 0.5),
              ),
              onPressed: (_selectedScore == 0 || _isSubmitting)
                  ? null
                  : () async {
                      if (!mounted) return;
                      
                      final commentText = _commentController.text.trim();
                      final assessmentBloc = context.read<AssessmentBloc>();
                      
                      // Validar palabras ofensivas
                      final isOffensive = await _badWordsService.checkOffensiveText(commentText);
                      
                      if (!mounted) return;
                      
                      if (isOffensive) {
                        setState(() {
                          _isSubmitting = false;
                          _pendingOperation = false;
                          _errorMessage = l10n.offensiveText;
                        });
                        return;
                      }

                      setState(() {
                        _pendingOperation = true;
                        _isSubmitting = true;
                        _errorMessage = null; 
                      });
                      if (isEditing) {
                        assessmentBloc.add(
                          UpdateAssessmentEvent(
                            stationId: widget.stationId,
                            score: _selectedScore,
                            comment: commentText,
                          ),
                        );
                      } else {
                        assessmentBloc.add(
                          CreateAssessmentEvent(
                            stationId: widget.stationId,
                            score: _selectedScore,
                            comment: commentText,
                          ),
                        );
                      }
                    },
              child: _isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isEditing ? l10n.updateReview: l10n.sendReview, 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}