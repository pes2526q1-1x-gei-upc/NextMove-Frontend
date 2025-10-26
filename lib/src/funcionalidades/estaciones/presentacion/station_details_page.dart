import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/bicycle_station_details.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/ev_station_details.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';


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

class StationDetailsPage extends StatefulWidget {
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
    State<StationDetailsPage> createState() => _StationDetailsPageState();
}

class _StationDetailsPageState extends State<StationDetailsPage> {
    StationDetails? stationDetails;

    bool isLoading = true;
    String? error;

    @override
    void initState() {
        super.initState();
        if (widget.stationDetails != null) {
            stationDetails = widget.stationDetails;
            isLoading = false;
            return;
        }
        _loadStationDetails();
    }

    Future<void> _loadStationDetails() async {
    try {
        stationDetails = await getStationDetails(widget.stationType, widget.stationID);
        setState(() {
            isLoading = false;
        });
    }
    catch (e) {
        setState(() {
            error = e.toString();
            isLoading = false;
        });
        }
    }

    @override
    Widget build(BuildContext context) {
        if (isLoading) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
            );
        }
        if (error != null) {
            return Scaffold(
                appBar: AppBar(title: Text(AppLocalizations.of(context)!.error)),
                body: Center(child: Text(error!)),
            );
        }

        final String totalSlotsLabel = switch (widget.stationType) {
          StationType.bicycle => AppLocalizations.of(context)!.totalAnchors,
          StationType.electricVehicle => AppLocalizations.of(context)!.totalChargers,
        };
        final String availableSlotsLabel = switch (widget.stationType) {
          StationType.bicycle => AppLocalizations.of(context)!.availableAnchors,
          StationType.electricVehicle => AppLocalizations.of(context)!.availableChargers,
        };

        return Scaffold(
            appBar: AppBar(
                title: Text(stationDetails!.name),
            ),
            body: Center(
                child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            createDetailRow(context, Icons.location_on_sharp, AppLocalizations.of(context)!.address, stationDetails!.address),
                            const SizedBox(height: 8),
                            createDetailRow(context, Icons.event_seat, totalSlotsLabel, stationDetails!.totalSlots.toString()),
                            const SizedBox(height: 8),
                            createDetailRow(context, Icons.check_circle_outline, availableSlotsLabel, stationDetails!.availableSlots.toString()),
                            const SizedBox(height: 8),
                            Row( // rating
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                    Icon(Icons.star),
                                    SizedBox(width: 4),
                                    Text('${AppLocalizations.of(context)!.rating}: ', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                    createStarRatingRow(stationDetails!.rating),
                                    Text(
                                        '(${stationDetails!.rating % 2 == 0 ? (stationDetails!.rating ~/ 2) : (stationDetails!.rating / 2)}/5)',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                ],
                            ),
                            const SizedBox(height: 16),
                            if (widget.stationType == StationType.bicycle) ...[
                                createDetailRow(context, Icons.pedal_bike, AppLocalizations.of(context)!.availableBikes, (stationDetails as BicycleStationDetails).availableBikes.toString()),
                                const SizedBox(height: 8),
                                createDetailRow(context, Icons.directions_bike, AppLocalizations.of(context)!.availableMechanicalBikes, (stationDetails as BicycleStationDetails).availableMechanicalBikes.toString()),
                                const SizedBox(height: 8),
                                createDetailRow(context, Icons.electric_bike, AppLocalizations.of(context)!.availableElectricBikes, (stationDetails as BicycleStationDetails).availableElectricBikes.toString()),
                                const SizedBox(height: 8),
                                createDetailRowBool(context, Icons.electric_bike, AppLocalizations.of(context)!.electricRecharge, (stationDetails as BicycleStationDetails).electricRechargeStation),
                                const SizedBox(height: 8),
                                createDetailRowBool(context, Icons.anchor, AppLocalizations.of(context)!.canAnchorBikes, (stationDetails as BicycleStationDetails).canAnchorBikes),
                                const SizedBox(height: 8),
                                createDetailRowBool(context, Icons.directions_bike, AppLocalizations.of(context)!.canRentBikes, (stationDetails as BicycleStationDetails).canRentBikes),
                                const SizedBox(height: 8),
                                createDetailRow(context, Icons.info_outline, AppLocalizations.of(context)!.state, (stationDetails as BicycleStationDetails).state.localized(context)),
                            ],
                            if (widget.stationType == StationType.electricVehicle) ...[
                                createDetailRowBool(context, Icons.bolt, AppLocalizations.of(context)!.superFast, (stationDetails as EVStationDetails).isSuperFast),
                                const SizedBox(height: 8),
                                createDetailRow(context, Icons.lock_open, AppLocalizations.of(context)!.accessType, (stationDetails as EVStationDetails).accessType),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    AppLocalizations.of(context)!.connectors,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...((stationDetails as EVStationDetails).connectors.map((connector) => Card(
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

    Row createStarRatingRow(int rating) {
        List<Widget> stars = [];
        int fullStars = rating ~/ 2;
        bool hasHalfStar = rating % 2 == 1;

        for (int i = 0; i < fullStars; i++) {
            stars.add(const Icon(Icons.star, color: Colors.amber));
        }

        if (hasHalfStar) {
            stars.add(const Icon(Icons.star_half, color: Colors.amber));
        }
        
        while (stars.length < 5) {
            stars.add(const Icon(Icons.star_border, color: Colors.amber));
        }

        return Row(
            mainAxisSize: MainAxisSize.min,
            children: stars,
        );
    }
}





