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