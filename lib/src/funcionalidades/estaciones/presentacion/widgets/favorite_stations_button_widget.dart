import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/favorite_stations_list.dart';

class FavoriteStationsButtonWidget extends StatelessWidget {
  final StationType currentMode;

  const FavoriteStationsButtonWidget({
    super.key,
    required this.currentMode,
  });

  void _navigateToFavoriteStations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoriteStationsList(stationType: currentMode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.45 : 0.18);

    return Positioned(
      top: 190,
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
