import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/stations_cache.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/bloc/station_list_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';

class StationList extends StatelessWidget {
  final StationType stationType;
  final double latitude;
  final double longitude;
  const StationList({
    super.key,
    required this.stationType,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => StationListBloc(context.read<StationsCache>())
        ..add(
          LoadStationListEvent(
            stationType: stationType,
            latitude: latitude,
            longitude: longitude,
          ),
        ),
      child: BlocListener<StationListBloc, StationListState>(
        listener: (context, state) {
          if (state is StationListToggleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<StationListBloc, StationListState>(
          builder: (context, state) {
            if (state is StationListLoading) {
              return Scaffold(
                appBar: AppBar(title: Text(l10n.stations)),
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (state is StationListError) {
              return Scaffold(
                appBar: AppBar(title: Text(l10n.stations)),
                body: Center(child: Text('${l10n.error}: ${state.message}')),
              );
            } else if (state is StationListLoaded ||
                state is StationListToggleError) {
              final allStationDetails = state is StationListLoaded
                  ? state.stations
                  : (state as StationListToggleError).stations;
              return Scaffold(
                appBar: AppBar(title: Text(l10n.stations)),
                body: ListView.builder(
                  itemCount: allStationDetails.length,
                  itemBuilder: (context, i) {
                    final stationDetails = allStationDetails[i];
                    return ListTile(
                      title: Text(stationDetails.address ?? "N/A"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Consumer<StationsCache>(
                            builder: (context, cache, child) {
                              final cachedStation = cache.getStation(stationDetails.id);
                              final isFavorite = cachedStation?.isFavorite ?? stationDetails.isFavorite;
                              final starColor = switch (isFavorite) {
                                true => Colors.yellow[700],
                                false => null,
                                null => Colors.grey[300],
                              };
                              return IconButton(
                                icon: Icon(
                                  (isFavorite ?? false)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: starColor,
                                ),
                                onPressed: () {
                                  context.read<StationListBloc>().add(
                                    ToggleFavoriteEvent(
                                      stationId: stationDetails.id,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            stationDetails.distanceKm != null
                                ? '${stationDetails.distanceKm!.toStringAsFixed(2)} km'
                                : "N/A km",
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
                appBar: AppBar(title: Text(l10n.stations)),
                body: Center(child: Text(l10n.unknownState)),
              );
            }
          },
        ),
      ),
    );
  }
}
