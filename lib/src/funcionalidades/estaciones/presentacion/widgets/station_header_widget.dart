import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/utils/create_star_rating_row.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/widgets/station_assessments_page.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/rate_station_bottom_sheet_widget.dart';

class StationHeaderWidget extends StatelessWidget {
  final StationDetails station;
  final Color themeColor;

  const StationHeaderWidget({
    super.key,
    required this.station,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Nombre y Dirección ---
        Text(
          station.name ?? l10n.unknown,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_rounded, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                station.address ?? l10n.unknown,
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.3),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // --- FILA DE ACCIONES (Valoración + Ver Opiniones + Botón Valorar) ---
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8, 
          runSpacing: 8,
          children: [
            // 1. Estrellas y Puntuación
            if (station.rating != null) ...[
              createStarRatingRow(station.rating!),
              Text(
                '(${station.rating! % 2 == 0 ? (station.rating! ~/ 2) : (station.rating! / 2).toStringAsFixed(1)})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              
              // SEPARADOR VERTICAL
              Container(width: 1, height: 16, color: Colors.grey[300]),

              // 2. BOTÓN "VER OPINIONES" 
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StationReviewsPage(
                        stationName: station.name ?? l10n.station,
                        themeColor: themeColor,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    l10n.seeOpinions,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ] else 
               Text(
                l10n.withoutOpinions, 
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            
            // 3. BOTÓN "VALORAR"
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => RateStationBottomSheet(
                    stationName: station.name ?? l10n.station,
                    themeColor: themeColor,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: themeColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, size: 14, color: themeColor),
                    const SizedBox(width: 4),
                    Text(
                      l10n.rate, 
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}