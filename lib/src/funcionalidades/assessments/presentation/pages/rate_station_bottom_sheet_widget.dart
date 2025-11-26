import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_event.dart';

class RateStationBottomSheet extends StatefulWidget {
  final String stationId;
  final String stationName;
  final Color themeColor;

  const RateStationBottomSheet({
    super.key,
    required this.stationId,
    required this.stationName,
    required this.themeColor,
  });

  @override
  State<RateStationBottomSheet> createState() => _RateStationBottomSheetState();
}

class _RateStationBottomSheetState extends State<RateStationBottomSheet> {
  int _selectedScore = 0; 
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Usamos MediaQuery para saber cuanto espacio ocupa el teclado
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Título ---
          Text(
            l10n.reviewStation, 
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.stationName,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          // --- Selector de Estrellas ---
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
                        : Colors.grey[300],
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            _getRatingLabel(_selectedScore),
            style: TextStyle(
              color: _selectedScore > 0 ? Colors.amber[800] : Colors.transparent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 30),

          // --- Campo de Descripción ---
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7), 
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: l10n.writeYourOpinion, 
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- Botón Enviar ---
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
                // Deshabilitar visualmente si no ha seleccionado estrellas
                disabledBackgroundColor: widget.themeColor.withOpacity(0.5),
              ),
              onPressed: _selectedScore == 0
                  ? null // Bloqueado si no hay estrellas
                  : () {
                    String id = widget.stationId;
                    debugPrint("station id: $id");
                    debugPrint("Score: $_selectedScore");
                    debugPrint("Comentario: ${_commentController.text}");
                    context.read<AssessmentBloc>().add(
                      CreateAssessmentEvent(
                        stationId: widget.stationId, 
                        score: _selectedScore,
                        comment: _commentController.text,
                      ),
                    );
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.thankYouForYourReview)),
                    );
                  },
              child: Text(
                l10n.sendReview, 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para mostrar texto según las estrellas 
  String _getRatingLabel(int score) {
    final l10n = AppLocalizations.of(context)!;
    switch (score) {
      case 1: return l10n.bad;
      case 2: return l10n.regular;
      case 3: return l10n.good;
      case 4: return l10n.veryGood;
      case 5: return l10n.excellent;
      default: return "";
    }
  }
}