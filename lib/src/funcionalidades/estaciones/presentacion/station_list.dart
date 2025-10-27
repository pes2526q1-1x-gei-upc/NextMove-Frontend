import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';

class StationList extends StatelessWidget {
  final StationType stationType;
  final double latitude;
  final double longitude;
  const StationList({super.key, required this.stationType, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    print('Fetching stations for $stationType at ($latitude, $longitude)');
    Future<List<StationDetails>?> allStationDetailsFuture = switch (stationType) {
      StationType.bicycle => getAllNearbyBicycleStationDetails(latitude, longitude),
      StationType.electricVehicle => getAllNearbyEVStationDetails(latitude, longitude),
    };

    return FutureBuilder<List<StationDetails>?>(
      future: allStationDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.stations),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.stations),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          final allStationDetails = snapshot.data ?? [];
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.stations),
            ),
            body: ListView.builder(
              itemCount: allStationDetails.length,
              itemBuilder: (context, i) {
                final stationDetails = allStationDetails[i];
                return ListTile(
                  title: Text(stationDetails.address),
                  trailing: Text('${stationDetails.distanceKm!.toStringAsFixed(2)} km'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StationDetailsPage(
                        stationID: stationDetails.id,
                        stationType: stationType,
                        stationDetails: stationDetails,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}