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
    if (station.rating == null) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        createStarRatingRow((station.rating! * 2).round()),
        
        const SizedBox(width: 8),
        Text(
          '(${station.rating!.toStringAsFixed(1)})',
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