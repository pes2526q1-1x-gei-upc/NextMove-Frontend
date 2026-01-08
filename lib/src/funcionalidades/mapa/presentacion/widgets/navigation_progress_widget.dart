import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class NavigationProgressWidget extends StatelessWidget {
  final int remainingSeconds;
  final int remainingDistance;

  const NavigationProgressWidget({
    super.key,
    required this.remainingSeconds,
    required this.remainingDistance,
  });

  String _formatDistance(int meters) {
    if (meters < 1000) {
      return '$meters m';
    } else {
      final km = (meters / 1000).toStringAsFixed(1);
      return '$km km';
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '< 1 min';
    final minutes = (seconds / 60).ceil();
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) return '$hours h';
      return '$hours h $mins min';
    }
  }
  
  String _formatArrivalTime() {
     final now = DateTime.now();
     final arrival = now.add(Duration(seconds: remainingSeconds));
     return '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;  
    final isDark = theme.brightness == Brightness.dark;

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
              // Time remaining
              Row(
                children: [
                   Icon(
                    Icons.access_time_filled_rounded,
                    size: 24,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDuration(remainingSeconds),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        '${l10n.arrival}: ${_formatArrivalTime()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          height: 1.1,
                        ),
                      ),
                    ],
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
