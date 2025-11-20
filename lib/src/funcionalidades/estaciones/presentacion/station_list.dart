import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/bloc/station_list_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';

class StationList extends StatelessWidget {
  final StationType stationType;
  final double latitude;
  final double longitude;
  const StationList({super.key, required this.stationType, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => StationListBloc()..add(LoadStationListEvent(stationType: stationType, latitude: latitude, longitude: longitude)),
      child: BlocBuilder<StationListBloc, StationListState>(
        builder: (context, state) {
          if (state is StationListLoading) {
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.stations),
              ),
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is StationListError) {
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.stations),
              ),
              body: Center(child: Text('${l10n.error}: ${state.message}')),
            );
          } else if (state is StationListLoaded) {
            final allStationDetails = state.stations;
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.stations),
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
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.stations),
              ),
              body: Center(child: Text(l10n.unknownState)),
            );
          }
        },
      ),
    );
  }
}