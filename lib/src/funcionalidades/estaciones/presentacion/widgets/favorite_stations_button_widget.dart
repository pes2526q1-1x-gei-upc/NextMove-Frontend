import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/favorite_stations_list.dart';

class FavoriteStationsButtonWidget extends StatelessWidget {
  const FavoriteStationsButtonWidget({
    super.key,
  });

  void _navigateToFavoriteStations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FavoriteStationsList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.45 : 0.18);

    return Positioned(
      top: 190, // 130 + 50 (altura del botón anterior) + 10 (espacio)
      right: 16,
      child: GestureDetector(
        onTap: () => _navigateToFavoriteStations(context),
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
            Icons.star_border,
            color: theme.colorScheme.onSurface,
            size: 28,
          ),
        ),
      ),
    );
  }
}
