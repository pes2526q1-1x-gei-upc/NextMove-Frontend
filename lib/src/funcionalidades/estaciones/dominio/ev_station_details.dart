import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_details.dart';

enum EVType {
  electric,
  hybridPlugin,
}

enum PowerType {
  AC,
  DC,
}

enum SpeedType {
  superFast,
  fast,
  semiFast,
}

enum ConnectionType {
  css2,
  chademo,
  mennekes,
  shucko,
}

class EVStationDetails extends StationDetails {
  final int power;
  final EVType vehicleType;
  final PowerType powerType;
  final SpeedType speedType;
  final ConnectionType connectionType;
  final String chargerType;

  EVStationDetails({
    required super.name,
    required super.address,
    required super.availableSlots,
    required super.totalSlots,
    required super.rating,
    required this.power,
    required this.vehicleType,
    required this.powerType,
    required this.speedType,
    required this.connectionType,
    required this.chargerType,
  });
}