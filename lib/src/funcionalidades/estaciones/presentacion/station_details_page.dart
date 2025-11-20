import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/bloc/station_details_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/utils/create_star_rating_row.dart';


extension ConnectionTypeLocalization on ConnectionType {
  String localized(BuildContext context) {
    switch (this) {
      case ConnectionType.css2:
        return AppLocalizations.of(context)!.css2;
      case ConnectionType.chademo:
        return AppLocalizations.of(context)!.chademo;
      case ConnectionType.mennekes:
        return AppLocalizations.of(context)!.mennekes;
      case ConnectionType.shucko:
        return AppLocalizations.of(context)!.shucko;
    }
  }
}

extension ConnectorStatusLocalization on ConnectorStatus {
    String localized(BuildContext context) {
        switch (this) {
            case ConnectorStatus.available:
                return AppLocalizations.of(context)!.available;
            case ConnectorStatus.occupied:
                return AppLocalizations.of(context)!.occupied;
            case ConnectorStatus.unavailable:
                return AppLocalizations.of(context)!.unavailable;
        }
    }
}

extension BicycleStationStateLocalization on BicycleStationState {
    String localized(BuildContext context) {
        switch (this) {
            case BicycleStationState.operational:
                return AppLocalizations.of(context)!.operational;
            case BicycleStationState.closed:
                return AppLocalizations.of(context)!.closed;
        }
    }
}

class StationDetailsPage extends StatelessWidget {
    final StationType stationType;
    final String stationID;
    final StationDetails? stationDetails;

    const StationDetailsPage({
        super.key,
        required this.stationType,
        required this.stationID,
        this.stationDetails,
    });

    @override
    Widget build(BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return BlocProvider(
            create: (context) => StationDetailsBloc()
                ..add(LoadStationDetailsEvent(stationID, stationType, stationDetails)),
            child: BlocBuilder<StationDetailsBloc, StationDetailsState>(
                builder: (context, state) {
                    if (state is StationDetailsLoading) {
                        return const Scaffold(
                            body: Center(child: CircularProgressIndicator()),
                        );
                    } else if (state is StationDetailsError) {
                        return Scaffold(
                            appBar: AppBar(title: Text(AppLocalizations.of(context)!.error)),
                            body: Center(child: Text(state.message)),
                        );
                    } else if (state is StationDetailsLoaded) {
                        final stationDetails = state.stationDetails;
                        return _buildDetailsPage(context, stationDetails);
                    } else {
                        return Scaffold(
                            body: Center(child: Text(l10n.unknownState)),
                        );
                    }
                },
            ),
        );
    }

    Scaffold _buildDetailsPage(BuildContext context, StationDetails stationDetails) {
        final String totalSlotsLabel = switch (stationType) {
          StationType.bicycle => AppLocalizations.of(context)!.totalAnchors,
          StationType.electricVehicle => AppLocalizations.of(context)!.totalChargers,
        };
        final String availableSlotsLabel = switch (stationType) {
          StationType.bicycle => AppLocalizations.of(context)!.availableAnchors,
          StationType.electricVehicle => AppLocalizations.of(context)!.availableChargers,
        };

        final bikeDetails = stationType == StationType.bicycle ? stationDetails as BicycleStationDetails : null;
        final evDetails = stationType == StationType.electricVehicle ? stationDetails as EVStationDetails : null;

        return Scaffold(
            appBar: AppBar(
                title: Text(stationDetails.name),
            ),
            body: Center(
                child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            createDetailRow(context, Icons.location_on_sharp, AppLocalizations.of(context)!.address, stationDetails.address),
                            const SizedBox(height: 8),
                            createDetailRow(context, Icons.event_seat, totalSlotsLabel, stationDetails.totalSlots.toString()),
                            const SizedBox(height: 8),
                            createDetailRow(context, Icons.check_circle_outline, availableSlotsLabel, stationDetails.availableSlots.toString()),
                            const SizedBox(height: 8),
                            Row( // rating
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                    Icon(Icons.star),
                                    SizedBox(width: 4),
                                    Text('${AppLocalizations.of(context)!.rating}: ', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                    createStarRatingRow(stationDetails.rating),
                                    Text(
                                        '(${stationDetails.rating % 2 == 0 ? (stationDetails.rating ~/ 2) : (stationDetails.rating / 2)}/5)',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                ],
                            ),
                            const SizedBox(height: 16),
                            if (bikeDetails != null) ...[
                                createDetailRow(context, Icons.pedal_bike, AppLocalizations.of(context)!.availableBikes, bikeDetails.availableBikes.toString()),
                                const SizedBox(height: 8),
                                createDetailRow(context, Icons.directions_bike, AppLocalizations.of(context)!.availableMechanicalBikes, bikeDetails.availableMechanicalBikes.toString()),
                                const SizedBox(height: 8),
                                createDetailRow(context, Icons.electric_bike, AppLocalizations.of(context)!.availableElectricBikes, bikeDetails.availableElectricBikes.toString()),
                                const SizedBox(height: 8),
                                createDetailRowBool(context, Icons.electric_bike, AppLocalizations.of(context)!.electricRecharge, bikeDetails.electricRechargeStation),
                                const SizedBox(height: 8),
                                createDetailRowBool(context, Icons.anchor, AppLocalizations.of(context)!.canAnchorBikes, bikeDetails.canAnchorBikes),
                                const SizedBox(height: 8),
                                createDetailRowBool(context, Icons.directions_bike, AppLocalizations.of(context)!.canRentBikes, bikeDetails.canRentBikes),
                                const SizedBox(height: 8),
                                createDetailRow(context, Icons.info_outline, AppLocalizations.of(context)!.state, bikeDetails.state.localized(context)),
                            ],
                            if (evDetails != null) ...[
                                createDetailRowBool(context, Icons.bolt, AppLocalizations.of(context)!.superFast, evDetails.isSuperFast),
                                const SizedBox(height: 8),
                                createDetailRow(context, Icons.lock_open, AppLocalizations.of(context)!.accessType, evDetails.accessType),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    AppLocalizations.of(context)!.connectors,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...(evDetails.connectors.map((connector) => Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: Icon(Icons.cable),
                                    title: Text(connector.connectionType.localized(context)),
                                    subtitle: Text(connector.powerKw == 0 ? AppLocalizations.of(context)!.unknownPower : '${connector.powerKw} kW'),
                                    trailing: Text(connector.status.localized(context),
                                      style: TextStyle(
                                        color: switch (connector.status) {
                                          ConnectorStatus.available => Colors.green,
                                          ConnectorStatus.occupied => Colors.orange,
                                          ConnectorStatus.unavailable => Colors.red,
                                        },
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ))),
                            ]
                          ],
                        ),
                    ),
                ),
            ),
        );
    }

    Row createDetailRow(BuildContext context, IconData icon, String label, String value) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
                Icon(icon),
                SizedBox(width: 4),
                Text('$label: ', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                  (value == '' ? AppLocalizations.of(context)!.unknown : value),
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  ),
                ),
            ],
        );
    }

    Row createDetailRowBool(BuildContext context, IconData icon, String label, bool value) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
                Icon(icon),
                SizedBox(width: 4),
                Text('$label: ', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Icon(
                    value ? Icons.check : Icons.close,
                    color: value ? Colors.green : Colors.red,
                ),
            ],
        );
    }

    
}





