import 'package:nextmove_app/src/funcionalidades/estaciones/datos/station_details_page.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/bicycle_station_details.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/ev_station_details.dart';

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

    StationDetails({
    required this.id,
    required this.name,
    required this.address,
    required this.totalSlots,
    required this.availableSlots,
    required this.rating,
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

Future<EVStationDetails?> getEVStationDetails(String stationID) async {
    return await DBgetEVStationDetails(stationID);
}