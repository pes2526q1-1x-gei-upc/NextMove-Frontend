import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/presentacion/widgets/recorded_routes_list.dart';

class RouteHistoryButtonWidget extends StatelessWidget {
  const RouteHistoryButtonWidget({
    super.key,
  });

  void _navigateToRouteHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RouteHistoryList(), 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shadowColor = Colors.black.withOpacity(isDark ? 0.45 : 0.18);

    return Positioned(
      top: 130, // 70 + 50 (altura del botón anterior) + 10 (espacio)
      right: 16,
      child: GestureDetector(
        onTap: () => _navigateToRouteHistory(context),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                spreadRadius: 1,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.history,
            color: theme.colorScheme.onSurface,
            size: 28,
          ),
        ),
      ),
    );
  }
}
