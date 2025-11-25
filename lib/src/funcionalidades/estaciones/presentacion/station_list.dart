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
                    title: Text(stationDetails.address ?? "N/A"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            (stationDetails.isFavorite ?? false) ? Icons.star : Icons.star_border,
                            color: switch (stationDetails.isFavorite) {
                              true => Colors.yellow[700],
                              false => null,
                              null => Colors.grey[350],
                            },
                          ),
                          onPressed: () {
                            context.read<StationListBloc>().add(ToggleFavoriteEvent(stationId: stationDetails.id));
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          stationDetails.distanceKm != null ? '${stationDetails.distanceKm!.toStringAsFixed(2)} km' : "N/A km",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
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