import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_event.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_entity.dart';

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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.existingAssessment != null;
    final theme = Theme.of(context);
    final buttonOnColor =
        ThemeData.estimateBrightnessForColor(widget.themeColor) ==
                Brightness.dark
            ? Colors.white
            : Colors.black.withOpacity(0.85);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.5 : 0.15,
            ),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
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
              // Espaciador invisible para centrar el título si hay icono de borrar
              if (isEditing) const SizedBox(width: 48), 
              
              Text(
                isEditing ? l10n.editReview : l10n.reviewStation,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
                            child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey))
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx); // Cerrar alerta
                              
                              // Evento BLoC: Eliminar
                              context.read<AssessmentBloc>().add(
                                DeleteAssessmentEvent(stationId: widget.stationId)
                              );
                              
                              Navigator.pop(context); // Cerrar BottomSheet
                              
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
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
                        : theme.colorScheme.onSurface.withOpacity(0.25),
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            _getRatingLabel(_selectedScore, l10n),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _selectedScore > 0
                  ? Colors.amber[700]
                  : Colors.transparent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 30),

          // --- CAMPO DE COMENTARIOS ---
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(
                theme.brightness == Brightness.dark ? 0.35 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.dividerColor.withOpacity(
                  theme.brightness == Brightness.dark ? 0.4 : 0.6,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    theme.brightness == Brightness.dark ? 0.45 : 0.08,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: l10n.writeYourOpinion, 
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- BOTÓN DE ACCIÓN (CREAR O ACTUALIZAR) ---
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              // Calculamos el color de texto según el contraste del fondo
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeColor,
                foregroundColor: buttonOnColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: widget.themeColor.withOpacity(0.4),
                overlayColor: buttonOnColor.withOpacity(0.08),
                disabledBackgroundColor: widget.themeColor.withOpacity(0.5),
                disabledForegroundColor: buttonOnColor.withOpacity(0.6),
              ),
              onPressed: _selectedScore == 0
                  ? null
                  : () {
                      if (isEditing) {
                        // MODO EDICIÓN: Evento Update
                        context.read<AssessmentBloc>().add(
                          UpdateAssessmentEvent(
                            stationId: widget.stationId,
                            score: _selectedScore,
                            comment: _commentController.text,
                          ),
                        );
                      } else {
                        // MODO CREACIÓN: Evento Create
                        context.read<AssessmentBloc>().add(
                          CreateAssessmentEvent(
                            stationId: widget.stationId,
                            score: _selectedScore,
                            comment: _commentController.text,
                          ),
                        );
                      }
                      
                      Navigator.pop(context); // Cerrar
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing 
                            ? l10n.updatedReview
                            : l10n.thankYouForYourReview),
                        ),
                      );
                    },
              child: Text(
                isEditing ? l10n.updateReview : l10n.sendReview,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: buttonOnColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}