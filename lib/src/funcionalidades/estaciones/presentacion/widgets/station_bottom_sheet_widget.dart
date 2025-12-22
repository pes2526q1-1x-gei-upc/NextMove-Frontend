import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/stations_cache.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/ev_stats_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/bicycle_stats_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/star_rating_row_bottom_sheet.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_event.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_state.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/data/repositories/assessment_repository.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/bloc/station_list_bloc.dart';
import 'package:provider/provider.dart';

class StationBottomSheet extends StatelessWidget {
  const StationBottomSheet({
    super.key,
    required this.context,
    required this.stationId,
    required this.state,
  });

  final BuildContext context;
  final String stationId;
  final MapLoadedState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBicycle = state.currentMode == StationType.bicycle;
    final theme = Theme.of(context);
    final themeColor = isBicycle
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;
    final onThemeColor = isBicycle
        ? theme.colorScheme.onSecondary
        : theme.colorScheme.onPrimary;
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = theme.colorScheme.onSurfaceVariant;

    return Consumer<StationsCache>(
      builder: (context, cache, child) {
        final station = cache.getStation(stationId);
        if (station == null) return const SizedBox();

        return BlocProvider(
          create: (context) =>
              AssessmentBloc(assessmentRepository: AssessmentRepository())
                ..add(GetStationAssessmentInfoEvent(stationId: station.id)),
          child: BlocProvider<StationListBloc>(
            create: (context) =>
                StationListBloc(context.read<StationsCache>())..add(
                  LoadStationListEvent(
                    stationType: state.currentMode,
                    latitude: state.userLocation?.latitude ?? 41.3851,
                    longitude: state.userLocation?.longitude ?? 2.1734,
                  ),
                ),
            child: Builder(
              builder: (context) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
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
                              color: theme.dividerColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- CABECERA ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    station.name ?? l10n.unknown,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    station.address ?? l10n.unknown,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      color: mutedColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.directions_walk_rounded,
                                    size: 16,
                                    color: themeColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    station.distanceKm != null
                                        ? '${station.distanceKm!.toStringAsFixed(1)} km'
                                        : '- km',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: themeColor,
                                          fontSize: 12,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            FavoriteToggleButton(station: station),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // --- RATING ACTUALIZADO ---
                        BlocBuilder<AssessmentBloc, AssessmentState>(
                          builder: (context, assessmentState) {
                            double? realRating;
                            if (assessmentState.totalAssessments > 0) {
                              realRating = assessmentState.averageScore;
                            } else if (assessmentState.status ==
                                AssessmentStatus.success) {
                              realRating = null;
                            } else {
                              realRating = station.rating;
                            }

                            final displayStation = station.copyWith(
                              rating: realRating,
                            );

                            if (displayStation.rating != null) {
                              return Column(
                                children: [
                                  StarRatingRowBottomSheet(
                                    station: displayStation,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star_outline_rounded,
                                      size: 18,
                                      color: mutedColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      l10n.withoutOpinions,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: mutedColor,
                                            fontSize: 13,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),

                        // --- STATS ---
                        station is BicycleStationDetails
                            ? BicycleStatsWidget(station: station)
                            : station is EVStationDetails
                            ? EVStatsWidget(station: station)
                            : const SizedBox.shrink(),

                        const SizedBox(height: 20),

                        // --- BOTÓN DE ACCIÓN ---
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              foregroundColor: onThemeColor,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              shadowColor: themeColor.withValues(alpha: 0.4),
                              overlayColor: onThemeColor.withValues(alpha: 0.1),
                            ),
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => StationDetailsPage(
                                    stationID: station.id,
                                    stationType: state.currentMode,
                                    stationDetails: station,
                                  ),
                                ),
                              );

                              if (context.mounted) {
                                context.read<AssessmentBloc>().add(
                                  GetStationAssessmentInfoEvent(
                                    stationId: station.id,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              l10n.information,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: onThemeColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class FavoriteToggleButton extends StatelessWidget {
  const FavoriteToggleButton({super.key, required this.station});

  final StationDetails station;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StationListBloc, StationListState>(
      builder: (context, state) {
        final currentStation =
            (state is StationListLoaded || state is StationListToggleError)
            ? (state is StationListLoaded
                      ? state.stations
                      : (state as StationListToggleError).stations)
                  .where((s) => s.id == station.id)
                  .firstOrNull
            : null;
        final isFavorite = currentStation?.isFavorite ?? station.isFavorite;
        final starColor = switch (isFavorite) {
          true => Colors.yellow[700],
          false => null,
          null => Colors.grey[300],
        };
        return IconButton(
          icon: Icon(
            (isFavorite ?? false) ? Icons.star : Icons.star_border,
            color: starColor,
          ),
          onPressed: () {
            context.read<StationListBloc>().add(
              ToggleFavoriteEvent(stationId: station.id),
            );
          },
        );
      },
    );
  }
}
