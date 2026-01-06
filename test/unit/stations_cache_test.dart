import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/stations_cache.dart';

void main() {
  group('StationsCache', () {
    late StationsCache cache;

    setUp(() {
      cache = StationsCache();
    });

    test('initially has no stations', () {
      expect(cache.getStation('1'), isNull);
      expect(cache.getAllStations(), isEmpty);
    });

    test('updateStation adds station to cache', () {
      final station = BicycleStationDetails(
        id: '1',
        name: 'Station 1',
        address: 'Address 1',
        latitude: 41.3851,
        longitude: 2.1734,
        totalSlots: 20,
        availableSlots: 15,
        availableMechanicalBikes: 10,
        availableElectricBikes: 5,
        electricRechargeStation: true,
        canAnchorBikes: true,
        canRentBikes: true,
        state: BicycleStationState.operational,
      );

      cache.updateStation(station);

      expect(cache.getStation('1'), station);
      expect(cache.getAllStations(), [station]);
    });

    test('updateStations adds multiple stations to cache', () {
      final station1 = BicycleStationDetails(
        id: '1',
        name: 'Station 1',
        latitude: 41.3851,
        longitude: 2.1734,
        totalSlots: 20,
        availableSlots: 15,
        availableMechanicalBikes: 10,
        availableElectricBikes: 5,
        electricRechargeStation: true,
        canAnchorBikes: true,
        canRentBikes: true,
        state: BicycleStationState.operational,
      );

      final station2 = BicycleStationDetails(
        id: '2',
        name: 'Station 2',
        latitude: 41.4036,
        longitude: 2.1744,
        totalSlots: 25,
        availableSlots: 20,
        availableMechanicalBikes: 15,
        availableElectricBikes: 5,
        electricRechargeStation: false,
        canAnchorBikes: true,
        canRentBikes: true,
        state: BicycleStationState.operational,
      );

      cache.updateStations([station1, station2]);

      expect(cache.getStation('1'), station1);
      expect(cache.getStation('2'), station2);
      expect(cache.getAllStations(), containsAll([station1, station2]));
    });

    test('updateStation overwrites existing station', () {
      final originalStation = BicycleStationDetails(
        id: '1',
        name: 'Station 1',
        latitude: 41.3851,
        longitude: 2.1734,
        totalSlots: 20,
        availableSlots: 15,
        availableMechanicalBikes: 10,
        availableElectricBikes: 5,
        electricRechargeStation: true,
        canAnchorBikes: true,
        canRentBikes: true,
        state: BicycleStationState.operational,
      );

      final updatedStation = BicycleStationDetails(
        id: '1',
        name: 'Station 1 Updated',
        latitude: 41.3851,
        longitude: 2.1734,
        totalSlots: 25,
        availableSlots: 20,
        availableMechanicalBikes: 15,
        availableElectricBikes: 5,
        electricRechargeStation: true,
        canAnchorBikes: true,
        canRentBikes: true,
        state: BicycleStationState.operational,
      );

      cache.updateStation(originalStation);
      cache.updateStation(updatedStation);

      expect(cache.getStation('1'), updatedStation);
      expect(cache.getAllStations().length, 1);
    });

    test('getAllStations returns copy of stations list', () {
      final station = BicycleStationDetails(
        id: '1',
        name: 'Station 1',
        latitude: 41.3851,
        longitude: 2.1734,
        totalSlots: 20,
        availableSlots: 15,
        availableMechanicalBikes: 10,
        availableElectricBikes: 5,
        electricRechargeStation: true,
        canAnchorBikes: true,
        canRentBikes: true,
        state: BicycleStationState.operational,
      );

      cache.updateStation(station);

      final stations = cache.getAllStations();
      expect(stations, [station]);

      stations.clear();
      expect(cache.getAllStations(), [station]);
    });
  });
}