import 'package:nextmove_app/src/funcionalidades/mapa/datos/MapHomePageData.dart';

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