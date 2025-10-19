import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/bicycle_station_details.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/ev_station_details.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_details.dart';

class StationDetailsPage extends StatefulWidget {
    final StationType stationType;
    final String stationID;

    const StationDetailsPage({
        super.key,
        required this.stationType,
        required this.stationID,
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
            error = 'Error'; //TODO: capturar error GraphQL
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
                appBar: AppBar(title: const Text('Error')),
                body: Center(child: Text(AppLocalizations.of(context)!.unknownError)),
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
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                    Icon(Icons.location_on_sharp),
                                    SizedBox(width: 4),
                                    Text('${AppLocalizations.of(context)!.address}: ', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                    Text(stationDetails!.address, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                            ),
                            const SizedBox(height: 8),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                        Icon(Icons.event_seat),
                                        SizedBox(width: 4),
                                        Text('$totalSlotsLabel: ', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                        Text('${stationDetails!.totalSlots}', style: Theme.of(context).textTheme.bodyLarge),
                                    ],
                                ),
                          const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_outline),
                                SizedBox(width: 4),
                                Text('$availableSlotsLabel: ', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                Text('${stationDetails!.availableSlots}', style: Theme.of(context).textTheme.bodyLarge),
                              ],
                            ),
                            const SizedBox(height: 8),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                        Icon(Icons.star),
                                        SizedBox(width: 4),
                                        Text('${AppLocalizations.of(context)!.rating}: ', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                        getRowRatingStars(stationDetails!.rating),
                                        Text(
                                            '(${stationDetails!.rating % 2 == 0 ? (stationDetails!.rating ~/ 2) : (stationDetails!.rating / 2)}/5)',
                                            style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                    ],
                                ),
                            const SizedBox(height: 16),
                            // WidgetCard(stationDetails: stationDetails),
                          ],
                        ),
                    ),
                ),
            ),
        );
    }
}

Row getRowRatingStars(int rating) {
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

class WidgetCard extends StatelessWidget {
  const WidgetCard({
    super.key,
    required this.stationDetails,
  });

  final StationDetails? stationDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(stationDetails!.name, style: Theme.of(context).textTheme.headlineSmall),
                        subtitle: Text(stationDetails!.address),
                    ),
                    const Divider(),
                    ListTile(
                        leading: const Icon(Icons.event_seat),
                        title: Text('Total slots'),
                        trailing: Text('${stationDetails!.totalSlots}'),
                    ),
                    ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text('Available slots'),
                        trailing: Text('${stationDetails!.availableSlots}'),
                    ),
                    if (stationDetails is BicycleStationDetails) ...[
                        const Divider(),
                        ListTile(
                            leading: const Icon(Icons.pedal_bike),
                            title: Text('Available bikes'),
                            trailing: Text('${(stationDetails as BicycleStationDetails).availableBikes}'),
                        ),
                        ListTile(
                            leading: const Icon(Icons.electric_bike),
                            title: Text('Electric recharge station'),
                            trailing: Icon(
                                (stationDetails as BicycleStationDetails).electricRechargeStation
                                    ? Icons.check
                                    : Icons.close,
                                color: (stationDetails as BicycleStationDetails).electricRechargeStation
                                    ? Colors.green
                                    : Colors.red,
                            ),
                        ),
                        ListTile(
                            leading: const Icon(Icons.anchor),
                            title: Text('Can anchor bikes'),
                            trailing: Icon(
                                (stationDetails as BicycleStationDetails).canAnchorBikes
                                    ? Icons.check
                                    : Icons.close,
                                color: (stationDetails as BicycleStationDetails).canAnchorBikes
                                    ? Colors.green
                                    : Colors.red,
                            ),
                        ),
                        ListTile(
                            leading: const Icon(Icons.directions_bike),
                            title: Text('Can rent bikes'),
                            trailing: Icon(
                                (stationDetails as BicycleStationDetails).canRentBikes
                                    ? Icons.check
                                    : Icons.close,
                                color: (stationDetails as BicycleStationDetails).canRentBikes
                                    ? Colors.green
                                    : Colors.red,
                            ),
                        ),
                        ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: Text('State'),
                            trailing: Text((stationDetails as BicycleStationDetails).state.name),
                        ),
                        ListTile(
                            leading: const Icon(Icons.anchor),
                            title: Text('Available anchors'),
                            trailing: Text('${(stationDetails as BicycleStationDetails).availableAnchors}'),
                        ),
                        ListTile(
                            leading: const Icon(Icons.directions_bike),
                            title: Text('Available mechanical bikes'),
                            trailing: Text('${(stationDetails as BicycleStationDetails).availableMechanicalBikes}'),
                        ),
                        ListTile(
                            leading: const Icon(Icons.electric_bike),
                            title: Text('Available electric bikes'),
                            trailing: Text('${(stationDetails as BicycleStationDetails).availableElectricBikes}'),
                        ),
                    ],
                    if (stationDetails is EVStationDetails) ...[
                        const Divider(),
                        ListTile(
                            leading: const Icon(Icons.bolt),
                            title: Text('Power'),
                            trailing: Text('${(stationDetails as EVStationDetails).power} kW'),
                        ),
                        ListTile(
                            leading: const Icon(Icons.directions_car),
                            title: Text('Vehicle type'),
                            trailing: Text((stationDetails as EVStationDetails).vehicleType.name),
                        ),
                        ListTile(
                            leading: const Icon(Icons.power),
                            title: Text('Power type'),
                            trailing: Text((stationDetails as EVStationDetails).powerType.name),
                        ),
                        ListTile(
                            leading: const Icon(Icons.speed),
                            title: Text('Speed type'),
                            trailing: Text((stationDetails as EVStationDetails).speedType.name),
                        ),
                        ListTile(
                            leading: const Icon(Icons.cable),
                            title: Text('Connection type'),
                            trailing: Text((stationDetails as EVStationDetails).connectionType.name),
                        ),
                        ListTile(
                            leading: const Icon(Icons.charging_station),
                            title: Text('Charger type'),
                            trailing: Text((stationDetails as EVStationDetails).chargerType),
                        ),
                    ],
                ],
            ),
        ),
    );
  }
}





