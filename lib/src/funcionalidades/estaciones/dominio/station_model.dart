import 'package:nextmove_app/src/funcionalidades/estaciones/datos/station_model.dart';

enum StationType {
    bicycle,
    electricVehicle,
}

class StationDetails {
    final String id;
    final String name;
    final String address;
    final int totalSlots;
    final int availableSlots;
    final int rating;
    final double? distanceKm;
    final double latitude;
    final double longitude;

    StationDetails({
    required this.id,
    required this.name,
    required this.address,
    required this.totalSlots,
    required this.availableSlots,
    required this.rating,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    });
}

enum BicycleStationState {
  operational,
  closed,
}

class BicycleStationDetails extends StationDetails {
  final int availableBikes;
  final bool electricRechargeStation;
  final bool canAnchorBikes;
  final bool canRentBikes;
  final BicycleStationState state;
  final int availableMechanicalBikes;
  final int availableElectricBikes;

  BicycleStationDetails({
    required super.id,
    required super.name,
    required super.address,
    required super.totalSlots,
    required super.availableSlots,
    required super.rating,
    required super.latitude,
    required super.longitude,
    super.distanceKm,
    required this.availableBikes,
    required this.electricRechargeStation,
    required this.canAnchorBikes,
    required this.canRentBikes,
    required this.state,
    required this.availableMechanicalBikes,
    required this.availableElectricBikes,
  });

  factory BicycleStationDetails.fromJson(Map<String, dynamic> data) {
    // print('Parsing station: id=${data['id']}, nombre=${data['nombre']}');
    return BicycleStationDetails(
      id: data['id'],
      name: data['nombre'],
      address: data['direccion'],
      latitude: (data['coordenadas']['latitude'] as num).toDouble(),
      longitude: (data['coordenadas']['longitude'] as num).toDouble(),
      totalSlots: data['plazasTotales'],
      availableSlots: data['anclajesDisponibles'],
      rating: 5, // TODO: obtenir valoració de la BD
      distanceKm: data['distanciaKm'] != null ? (data['distanciaKm'] as num).toDouble() : null,
      availableBikes: (data['bicisMecanicasDisponibles']) + (data['bicisElectricasDisponibles']),
      electricRechargeStation: data['estacionCargaElectrica'],
      canAnchorBikes: data['sePuedeAnclarBicis'],
      canRentBikes: data['sePuedenAlquilarBicis'],
      state: data['estado'] == "OPERATIVA" ? BicycleStationState.operational : BicycleStationState.closed,
      availableMechanicalBikes: data['bicisMecanicasDisponibles'],
      availableElectricBikes: data['bicisElectricasDisponibles'],
    );
  }
}

enum PowerType {
  ac,
  dc,
}

enum ConnectionType {
  css2,
  chademo,
  mennekes,
  shucko,
}

enum ConnectorStatus {
    available,
    occupied,
    unavailable,
}

class EVStationDetails extends StationDetails {
  final List<Connector> connectors;
  final String accessType;
  final bool isSuperFast;

  EVStationDetails({
    required super.id,
    required super.name,
    required super.address,
    required super.availableSlots,
    required super.totalSlots,
    required super.rating,
    required super.latitude,
    required super.longitude,
    super.distanceKm,
    required this.isSuperFast,
    required this.connectors,
    required this.accessType,
  });

  factory EVStationDetails.fromJson(Map<String, dynamic> data) {
    List<Connector> connectors = [];
    if (data['connectors'] != null) {
      for (var connectorData in data['connectors']) {
        connectors.add(Connector(
          connectionType: ConnectionType.values.firstWhere(
            (e) => e.name.toUpperCase() == (connectorData['type'] as String).toUpperCase(),
            orElse: () => ConnectionType.mennekes,
          ),
          powerKw: (connectorData['powerKw'] ?? 0).toDouble(),
          status: ConnectorStatus.values.firstWhere(
            (e) => e.name.toUpperCase() == (connectorData['status'] as String).toUpperCase(),
            orElse: () => ConnectorStatus.unavailable,
          ),
        ));
      }
    }
    // print('Parsing EV station: id=${data['id']}, name=${data['name']}');
    return EVStationDetails(
      id: data['id'],
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['coordinates']['latitude'] as num).toDouble(),
      longitude: (data['coordinates']['longitude'] as num).toDouble(),
      availableSlots: connectors.where((c) => c.status == ConnectorStatus.available).length,
      totalSlots: connectors.length,
      rating: 5, //TODO: rating real des de la BD
      distanceKm: data['distance'] != null ? (data['distance']).toDouble() : null,
      isSuperFast: data['isSuperFast'],
      connectors: connectors,
      accessType: data['accessType'] ?? '',
    );
  }
}

class Connector {
    final ConnectionType connectionType;
    final double powerKw;
    final ConnectorStatus status;

    Connector({
        required this.connectionType,
        required this.powerKw,
        required this.status,
    });
}


Future<List<StationDetails>?> getAllStationDetails(StationType stationType) async {
  switch (stationType) {
    case StationType.bicycle:
      return await getAllBicycleStationDetails();
    case StationType.electricVehicle:
      return await getAllEVStationDetails();
  }
}

Future<List<BicycleStationDetails>?> getAllBicycleStationDetails() async {
  return await DBgetAllBicycleStationDetails();
}

Future<List<EVStationDetails>?> getAllEVStationDetails() async {
  return await DBgetAllEVStationDetails();
}

Future<StationDetails?> getStationDetails(StationType stationType, String stationID) async {
    switch (stationType) {
        case StationType.bicycle:
            return await getBicycleStationDetails(stationID);
        case StationType.electricVehicle:
            return await getEVStationDetails(stationID);
    }
}

Future<BicycleStationDetails?> getBicycleStationDetails(String stationID) async {
    return await DBgetBicycleStationDetails(stationID);
}

Future<List<StationDetails>?> getAllNearbyBicycleStationDetails(double latitude, double longitude) async {
    return await DBgetAllNearbyBicycleStationDetails(latitude, longitude);
}

Future<EVStationDetails?> getEVStationDetails(String stationID) async {
    return await DBgetEVStationDetails(stationID);
}

Future<List<EVStationDetails>?> getAllNearbyEVStationDetails(double latitude, double longitude) async {
    return await DBgetAllNearbyEVStationDetails(latitude, longitude);
}