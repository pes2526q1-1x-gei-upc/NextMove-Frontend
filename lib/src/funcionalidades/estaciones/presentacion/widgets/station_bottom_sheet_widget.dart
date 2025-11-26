import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/EV_stats_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/bicycle_stats_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/star_rating_row_bottom_sheet.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_event.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_state.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/data/repositories/assessment_repository.dart';

class StationBottomSheet extends StatelessWidget {
  const StationBottomSheet({
    super.key,
    required this.context,
    required this.station,
    required this.state,
  });

  final BuildContext context;
  final StationDetails station;
  final MapLoadedState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBicycle = state.currentMode == StationType.bicycle;
    final themeColor = isBicycle ? Colors.blue : Colors.green;

    return BlocProvider(
      create: (context) => AssessmentBloc(
        assessmentRepository: AssessmentRepository(),
      )..add(GetStationAssessmentInfoEvent(stationId: station.id)),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BARRA SUPERIOR ---
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
              const SizedBox(height: 20),

              // --- CABECERA (Nombre y Distancia) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name ?? l10n.unknown,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          station.address ?? l10n.unknown,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Badge de distancia
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.directions_walk_rounded,
                            size: 16, color: themeColor),
                        const SizedBox(width: 4),
                        Text(
                          station.distanceKm != null
                              ? '${station.distanceKm!.toStringAsFixed(1)} km'
                              : '- km',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: 16),

              BlocBuilder<AssessmentBloc, AssessmentState>(
                builder: (context, assessmentState) {
                  final displayStation = (assessmentState.totalAssessments > 0)
                      ? station.copyWith(rating: assessmentState.averageScore)
                      : station;

                  if (displayStation.rating != null) {
                    return Column(
                      children: [
                        StarRatingRowBottomSheet(station: displayStation),
                        const SizedBox(height: 20),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // --- TARJETAS DE INFORMACIÓN ---
              if (station is BicycleStationDetails)
                BicycleStatsWidget(station: station as BicycleStationDetails)
              else if (station is EVStationDetails)
                EVStatsWidget(station: station as EVStationDetails),

              const SizedBox(height: 24),

              // --- BOTÓN DE ACCIÓN ---
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StationDetailsPage(
                          stationID: station.id,
                          stationType: state.currentMode,
                          stationDetails: station,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    l10n.information,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}