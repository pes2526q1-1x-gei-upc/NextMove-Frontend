import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_event.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_state.dart';
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
  bool _isSubmitting = false;
  bool _pendingOperation = false;
  String? _errorMessage;

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
            : Colors.black.withValues(alpha: 0.85);

<<<<<<< Updated upstream
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 
              theme.brightness == Brightness.dark ? 0.5 : 0.15,
            ),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
=======
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
          // No mostrar SnackBar, el error se mostrará en el TextField
        } else if (state.status == AssessmentStatus.success && _isSubmitting) {
          // Solo cerrar si acabamos de recibir éxito después de una operación pendiente
          setState(() {
            _isSubmitting = false;
            _pendingOperation = false;
            _errorMessage = null; // Limpiar error en caso de éxito
          });
          Navigator.pop(context); // Cerrar bottom sheet
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
>>>>>>> Stashed changes
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
                        : theme.colorScheme.onSurface.withValues(alpha: 0.25),
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
<<<<<<< Updated upstream
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 
                theme.brightness == Brightness.dark ? 0.35 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 
                  theme.brightness == Brightness.dark ? 0.4 : 0.6,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 
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
=======
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7), 
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _commentController,
                  maxLines: 3,
                  onChanged: (_) {
                    // Limpiar el error cuando el usuario empiece a escribir
                    if (_errorMessage != null) {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: l10n.writeYourOpinion, 
                    hintStyle: const TextStyle(color: Colors.grey),
                    errorText: null, // No mostrar error aquí, lo mostraremos abajo
                    errorBorder: InputBorder.none,
                    errorStyle: const TextStyle(height: 0),
                  ),
>>>>>>> Stashed changes
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
              // Calculamos el color de texto según el contraste del fondo
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeColor,
                foregroundColor: buttonOnColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: widget.themeColor.withValues(alpha: 0.4),
                overlayColor: buttonOnColor.withValues(alpha: 0.08),
                disabledBackgroundColor: widget.themeColor.withValues(alpha: 0.5),
                disabledForegroundColor: buttonOnColor.withValues(alpha: 0.6),
              ),
              onPressed: (_selectedScore == 0 || _isSubmitting)
                  ? null
                  : () {
                      setState(() {
                        _pendingOperation = true;
                        _isSubmitting = true;
                        _errorMessage = null; // Limpiar error anterior al intentar de nuevo
                      });
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
                      // No cerrar aquí, esperar a que el BlocListener maneje el resultado
                    },
<<<<<<< Updated upstream
              child: Text(
                isEditing ? l10n.updateReview : l10n.sendReview,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: buttonOnColor,
                  letterSpacing: 0.2,
                ),
              ),
=======
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
>>>>>>> Stashed changes
            ),
          ),
        ],
      ),
    ),
    );
  }
}