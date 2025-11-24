import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/utils/create_star_rating_row.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';

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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            station.name ?? "N/A",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(station.address ?? "N/A", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Text(
            station.distanceKm != null ? '${station.distanceKm!.toStringAsFixed(2)} km' : 'N/A km',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (station is BicycleStationDetails)
            _buildBicycleInfo(station as BicycleStationDetails, l10n)
          else if (station is EVStationDetails)
            _buildEVInfo(station as EVStationDetails, l10n),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: state.currentMode == StationType.bicycle
                    ? Colors.blue
                    : Colors.green,
                foregroundColor: Colors.white,
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
              child: Text(l10n.information),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBicycleInfo(
    BicycleStationDetails bikeStation,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        StarRatingRowBottomSheet(context: context, station: bikeStation),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pedal_bike),
            const SizedBox(width: 4),
            Text('${bikeStation.availableBikes ?? "N/A"}'),
            const SizedBox(width: 12),
            Text('( '),
            Icon(Icons.electric_bike),
            const SizedBox(width: 4),
            Text('${bikeStation.availableElectricBikes ?? "N/A"} / '),
            Icon(Icons.directions_bike),
            const SizedBox(width: 4),
            Text('${bikeStation.availableMechanicalBikes ?? "N/A"})'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_seat),
            const SizedBox(width: 4),
            Text('${bikeStation.availableSlots ?? "N/A"}'),
          ],
        ),
      ],
    );
  }

  Widget _buildEVInfo(EVStationDetails evStation, AppLocalizations l10n) {
    return Column(
      children: [
        StarRatingRowBottomSheet(context: context, station: evStation),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_seat),
            const SizedBox(width: 4),
            Text('${evStation.availableSlots ?? "N/A"} / ${evStation.totalSlots ?? "N/A"}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt),
            if (evStation.isSuperFast != null)
              Icon(
                evStation.isSuperFast! ? Icons.check : Icons.close,
                color: evStation.isSuperFast! ? Colors.green : Colors.red,
              )
            else
              Text("N/A"),
          ],
        ),
      ],
    );
  }
}

class StarRatingRowBottomSheet extends StatelessWidget {
  const StarRatingRowBottomSheet({
    super.key,
    required this.context,
    required this.station,
  });

  final BuildContext context;
  final StationDetails station;

  @override
  Widget build(BuildContext context) {
    if (station.rating == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("N/A"),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createStarRatingRow(station.rating!),
        Text(
          '(${station.rating! % 2 == 0 ? (station.rating! ~/ 2) : (station.rating! / 2)}/5)',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
