import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_details.dart';

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
  final int availableAnchors;
  final int availableMechanicalBikes;
  final int availableElectricBikes;

  BicycleStationDetails({
    required super.name,
    required super.address,
    required super.totalSlots,
    required super.availableSlots,
    required super.rating,
    required this.availableBikes,
    required this.electricRechargeStation,
    required this.canAnchorBikes,
    required this.canRentBikes,
    required this.state,
    required this.availableAnchors,
    required this.availableMechanicalBikes,
    required this.availableElectricBikes,
  });
}