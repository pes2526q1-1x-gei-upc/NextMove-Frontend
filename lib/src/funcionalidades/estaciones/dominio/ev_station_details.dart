import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_details.dart';

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
    required super.name,
    required super.address,
    required super.availableSlots,
    required super.totalSlots,
    required super.rating,
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
    return EVStationDetails(
      name: data['name'],
      address: data['address'],
      availableSlots: connectors.where((c) => c.status == ConnectorStatus.available).length,
      totalSlots: connectors.length,
      rating: 5, //TODO: rating real des de la BD
      isSuperFast: data['isSuperFast'],
      connectors: connectors,
      accessType: data['accessType'],
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