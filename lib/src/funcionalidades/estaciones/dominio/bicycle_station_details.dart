
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

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
