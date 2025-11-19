import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            station.address,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(station.address, style: const TextStyle(fontSize: 16)),
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
              child: const Text('Info'),
            ),
          ),
        ],
      ),
    );
  }
}
