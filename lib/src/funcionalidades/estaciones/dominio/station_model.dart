/*import 'package:nextmove_app/src/funcionalidades/mapa/datos/MapHomePageData.dart';

class StationModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  //final int availablePlaces;

  StationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    //required this.availablePlaces
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: (json['address'] ?? 'Dirección desconocida') as String,
      latitude: (json['coordinates']['latitude'] as num).toDouble(),
      longitude: (json['coordinates']['longitude'] as num).toDouble(),
      
    );
  }

  factory StationModel.fromJsonBicing(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] as String,
      name: json['nombre'] as String,
      latitude: (json['coordenadas']['lat'] as num).toDouble(),
      longitude: (json['coordenadas']['lon'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
    };
  }

}

Future<List<StationModel>?> getAllStations() async {
    return await DBgetAllStations();
}

Future<List<StationModel>?> getAllBikeStations() async {
    return await DBgetAllBikeStations();
  }*/

import 'package:nextmove_app/src/funcionalidades/estaciones/datos/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/datos/MapHomePageData.dart';
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