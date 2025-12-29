import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/navigation_route.dart';

class NavigationProgressWidget extends StatelessWidget {
  final int currentStepIndex;
  final NavigationRoute route;

  const NavigationProgressWidget({
    super.key,
    required this.currentStepIndex,
    required this.route,
  });

  String _formatDistance(int meters) {
    if (meters < 1000) {
      return '$meters m';
    } else {
      final km = (meters / 1000).toStringAsFixed(1);
      return '$km km';
    }
  }

  int _calculateRemainingDistance() {
    int totalDistance = 0;
    for (int i = currentStepIndex; i < route.steps.length; i++) {
      totalDistance += route.steps[i].distanceMeters;
    }
    return totalDistance;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final remainingDistance = _calculateRemainingDistance();
    final totalSteps = route.steps.length;

    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        color: isDark ? theme.cardColor : Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark 
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Step progress
              Row(
                children: [
                  Icon(
                    Icons.list_alt_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Paso ${currentStepIndex + 1}/$totalSteps',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              
              // Divider
              Container(
                height: 20,
                width: 1,
                color: theme.dividerColor,
              ),
              
              // Remaining distance
              Row(
                children: [
                  Icon(
                    Icons.place_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDistance(remainingDistance),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
