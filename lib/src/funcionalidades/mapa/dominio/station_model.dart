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

  Future<List<StationModel>?> ReqgetAllStations() async {
    return await getAllStations();
  }

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['coordinates']['latitude'] as num).toDouble(),
      longitude: (json['coordinates']['longitude'] as num).toDouble(),
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