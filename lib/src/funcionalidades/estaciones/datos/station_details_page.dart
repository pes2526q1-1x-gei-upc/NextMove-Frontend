import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/bicycle_station_details.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/ev_station_details.dart';

Future<BicycleStationDetails?> DBgetBicycleStationDetails(String stationID) async {
  //TODO: cridar GraphQL
    await Future.delayed(const Duration(milliseconds: 4000));
    return BicycleStationDetails(
        name: 'Bicycle Station $stationID',
        address: '123 Bike Lane',
        totalSlots: 10,
        availableSlots: 5,
        availableBikes: 5,
        electricRechargeStation: true,
        canAnchorBikes: true,
        canRentBikes: true,
        state: BicycleStationState.operational,
        availableAnchors: 5,
        availableMechanicalBikes: 3,
        availableElectricBikes: 2,
        rating: 6,
    );
}

Future<EVStationDetails?> DBgetEVStationDetails(String stationID) async {
  //TODO: cridar GraphQL
    await Future.delayed(const Duration(milliseconds: 2000));
    return EVStationDetails(
        name: 'EV Station $stationID',
        address: '456 EV Ave',
        availableSlots: 3,
        totalSlots: 8,
        isSuperFast: true,
        connectors: [
          Connector(
            connectionType: ConnectionType.css2,
            powerKw: 50,
            status: ConnectorStatus.available,
          ),
          Connector(
            connectionType: ConnectionType.chademo,
            powerKw: 100,
            status: ConnectorStatus.occupied,
          ),
          Connector(
            connectionType: ConnectionType.mennekes,
            powerKw: 22,
            status: ConnectorStatus.unavailable,
          ),
        ],
        rating: 8,
        accessType: 'Public',
    );
}