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
            station.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(station.address, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          if (station.distanceKm != null)
            Text(
              'Distance: ${station.distanceKm!.toStringAsFixed(2)} km',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            createStarRatingRow(bikeStation.rating),
            Text(
              '(${bikeStation.rating % 2 == 0 ? (bikeStation.rating ~/ 2) : (bikeStation.rating / 2)}/5)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pedal_bike),
            const SizedBox(width: 4),
            Text('${bikeStation.availableBikes}'),
            const SizedBox(width: 12),
            Text('( '),
            Icon(Icons.electric_bike),
            const SizedBox(width: 4),
            Text('${bikeStation.availableElectricBikes} / '),
            Icon(Icons.directions_bike),
            const SizedBox(width: 4),
            Text('${bikeStation.availableMechanicalBikes})'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_seat),
            const SizedBox(width: 4),
            Text('${bikeStation.availableSlots}'),
          ],
        ),
      ],
    );
  }

  Widget _buildEVInfo(EVStationDetails evStation, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Available Connectors: ${evStation.availableSlots}'),
            Text('Total Connectors: ${evStation.totalSlots}'),
          ],
        ),
        const SizedBox(height: 8),
        Text('Super Fast: ${evStation.isSuperFast ? 'Yes' : 'No'}'),
      ],
    );
  }
}
