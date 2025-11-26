import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/utils/create_star_rating_row.dart';

class StarRatingRowBottomSheet extends StatelessWidget {
  const StarRatingRowBottomSheet({
    super.key,
    required this.station,
  });

  final StationDetails station;

  @override
  Widget build(BuildContext context) {
    // Si no hay rating, retornamos un widget vacío para no ocupar espacio
    if (station.rating == null) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        createStarRatingRow(station.rating!),
        const SizedBox(width: 8),
        Text(
          '(${station.rating! % 2 == 0 ? (station.rating! ~/ 2) : (station.rating! / 2).toStringAsFixed(1)})',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}