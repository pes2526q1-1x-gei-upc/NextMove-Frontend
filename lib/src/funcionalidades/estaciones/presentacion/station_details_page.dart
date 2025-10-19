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
    return Scaffold(
        appBar: AppBar(
            title: Text(stationDetails!.name),
        ),
        body: Center(
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Text('Name: ${stationDetails!.name}'),
                        Text('Address: ${stationDetails!.address}'),
                        Text('Total slots: ${stationDetails!.totalSlots}'),
                        Text('Available slots: ${stationDetails!.availableSlots}'),
                        if (stationDetails is BicycleStationDetails) ...[
                            const SizedBox(height: 16),
                            Text('Available bikes: ${(stationDetails as BicycleStationDetails).availableBikes}'),
                            Text('Electric recharge station: ${(stationDetails as BicycleStationDetails).electricRechargeStation}'),
                            Text('Can anchor bikes: ${(stationDetails as BicycleStationDetails).canAnchorBikes}'),
                            Text('Can rent bikes: ${(stationDetails as BicycleStationDetails).canRentBikes}'),
                            Text('State: ${(stationDetails as BicycleStationDetails).state.name}'),
                            Text('Available anchors: ${(stationDetails as BicycleStationDetails).availableAnchors}'),
                            Text('Available mechanical bikes: ${(stationDetails as BicycleStationDetails).availableMechanicalBikes}'),
                            Text('Available electric bikes: ${(stationDetails as BicycleStationDetails).availableElectricBikes}'),
                        ],
                        if (stationDetails is EVStationDetails) ...[
                            const SizedBox(height: 16),
                            Text('Power: ${(stationDetails as EVStationDetails).power} kW'),
                            Text('Vehicle type: ${(stationDetails as EVStationDetails).vehicleType.name}'),
                            Text('Power type: ${(stationDetails as EVStationDetails).powerType.name}'),
                            Text('Speed type: ${(stationDetails as EVStationDetails).speedType.name}'),
                            Text('Connection type: ${(stationDetails as EVStationDetails).connectionType.name}'),
                            Text('Charger type: ${(stationDetails as EVStationDetails).chargerType}'),
                        ],
                    ],
                ),
            ),
        ),
    );
  }
}





