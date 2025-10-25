import 'package:nextmove_app/src/funcionalidades/mapa/datos/MapHomePageData.dart';

class StationModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  StationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] as String,
      name: json['name'] as String,
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
  }