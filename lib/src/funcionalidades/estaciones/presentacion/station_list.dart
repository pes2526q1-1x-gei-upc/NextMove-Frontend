import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_details.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';

class StationList extends StatelessWidget {
  final StationType stationType;
  const StationList({super.key, required this.stationType});

  @override
  Widget build(BuildContext context) {
    Future<List<StationDetails>?> allStationDetailsFuture = switch (stationType) {
      StationType.bicycle => getAllBicycleStationDetails(),
      StationType.electricVehicle => getAllEVStationDetails(),
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
                  title: Text(stationDetails.name),
                  trailing: Text('2,3 km'),
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