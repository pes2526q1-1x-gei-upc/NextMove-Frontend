import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/navigation_route.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class TurnInstructionWidget extends StatefulWidget {
  final RouteStep currentStep;
  final int distanceToNextStepMeters;
  final VoidCallback onCancel;

  const TurnInstructionWidget({
    super.key,
    required this.currentStep,
    required this.distanceToNextStepMeters,
    required this.onCancel,
  });

  @override
  State<TurnInstructionWidget> createState() => _TurnInstructionWidgetState();
}

class _TurnInstructionWidgetState extends State<TurnInstructionWidget> {
  String _formatDistance(int meters) {
    if (meters < 1000) {
      return '$meters m';
    } else {
      final km = (meters / 1000).toStringAsFixed(1);
      return '$km km';
    }
  }

  @override
  void didUpdateWidget(TurnInstructionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Forzar reconstrucción cuando cambian las propiedades
    if (oldWidget.currentStep != widget.currentStep ||
        oldWidget.distanceToNextStepMeters != widget.distanceToNextStepMeters) {
      // El widget se reconstruirá automáticamente
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Positioned(
      top: 130,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        color: isDark ? theme.cardColor : Colors.white,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark 
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Distance to next step
              Row(
                children: [
                  Icon(
                    Icons.navigation_rounded,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${l10n.enxmet} ${_formatDistance(widget.distanceToNextStepMeters)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[600],
                    ),
                  ),
                  const Spacer(),
                  // Cancel button
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close_rounded),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    tooltip: l10n.cancel,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Instruction text
              Text(
                widget.currentStep.instruction,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
