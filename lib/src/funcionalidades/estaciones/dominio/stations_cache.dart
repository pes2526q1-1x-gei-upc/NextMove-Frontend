import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

class StationsCache extends ChangeNotifier {
  final Map<String, StationDetails> _stations = {};

  StationDetails? getStation(String id) => _stations[id];

  void updateStation(StationDetails station) {
    _stations[station.id] = station;
    notifyListeners();
  }

  void updateStations(List<StationDetails> stations) {
    for (final station in stations) {
      _stations[station.id] = station;
    }
    notifyListeners();
  }

  List<StationDetails> getAllStations() => _stations.values.toList();
}