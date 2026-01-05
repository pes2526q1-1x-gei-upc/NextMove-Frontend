import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/presentacion/widgets/statistics_widget.dart';
import 'package:nextmove_app/src/shared/domain/track_statistics.dart';

class SavedTrackStatisticsPage extends StatelessWidget {
  const SavedTrackStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.routeStatistics),
      ),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is! MapLoadedState || state.recordedTrack == null) {
            return Center(
              child: Text(l10n.noRouteDataAvailable),
            );
          }

          final track = state.recordedTrack!;
          final duration = track.endTime.difference(track.startTime);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner de éxito
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.routeSavedSuccessfully,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),

                // Estadísticas
                StatisticsWidget(
                  track: RecordedTrackWrapper(track),
                  elapsedTime: duration,
                  l10n: l10n,
                ),

                const SizedBox(height: 24),

                // Botón para volver al mapa
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.map),
                    label: Text(l10n.backToMap),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Wrapper para adaptar RecordedTrack a TrackStatistics
class RecordedTrackWrapper implements TrackStatistics {
  final RecordedTrack _track;

  RecordedTrackWrapper(this._track);

  @override
  double get totalDistanceMeters => _track.totalDistanceMeters;

  @override
  double get averageSpeedKmH => _track.averageSpeedKmH;

  @override
  double get maxSpeedKmH => _track.maxSpeedKmH;

  @override
  double get elevationGainMeters => _track.elevationGainMeters;

  @override
  double get elevationLossMeters => _track.elevationLossMeters;

  @override
  double get co2SavedKG => _track.co2SavedKG;

  @override
  double get kcalBurned => _track.kcalBurned;
}