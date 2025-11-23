import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

void main() {
  group('BicycleStationDetails.fromJson', () {
    test('should parse valid JSON data correctly', () {
      final jsonData = {
        'id': '1',
        'nombre': 'Station 1',
        'direccion': 'Address 1',
        'coordenadas': {'latitude': 41.3851, 'longitude': 2.1734},
        'plazasTotales': 20,
        'anclajesDisponibles': 15,
        'bicisMecanicasDisponibles': 10,
        'bicisElectricasDisponibles': 5,
        'estacionCargaElectrica': true,
        'sePuedeAnclarBicis': true,
        'sePuedenAlquilarBicis': true,
        'estado': 'OPERATIVA',
        'distanciaKm': 1.5,
      };

      final station = BicycleStationDetails.fromJson(jsonData);

      expect(station.id, '1');
      expect(station.name, 'Station 1');
      expect(station.address, 'Address 1');
      expect(station.latitude, 41.3851);
      expect(station.longitude, 2.1734);
      expect(station.totalSlots, 20);
      expect(station.availableSlots, 15);
      expect(station.electricRechargeStation, true);
      expect(station.canAnchorBikes, true);
      expect(station.canRentBikes, true);
      expect(station.state, BicycleStationState.operational);
      expect(station.availableMechanicalBikes, 10);
      expect(station.availableElectricBikes, 5);
      expect(station.distanceKm, 1.5);
      expect(station.rating, 5);
    });

    test('should handle null values correctly', () {
      final jsonData = {
        'id': '2',
        'nombre': null,
        'direccion': null,
        'coordenadas': null,
        'plazasTotales': null,
        'anclajesDisponibles': null,
        'bicisMecanicasDisponibles': null,
        'bicisElectricasDisponibles': null,
        'estacionCargaElectrica': null,
        'sePuedeAnclarBicis': null,
        'sePuedenAlquilarBicis': null,
        'estado': null,
        'distanciaKm': null,
      };

      final station = BicycleStationDetails.fromJson(jsonData);

      expect(station.id, '2');
      expect(station.name, null);
      expect(station.address, null);
      expect(station.latitude, null);
      expect(station.longitude, null);
      expect(station.totalSlots, null);
      expect(station.availableSlots, null);
      expect(station.availableBikes, null);
      expect(station.electricRechargeStation, null);
      expect(station.canAnchorBikes, null);
      expect(station.canRentBikes, null);
      expect(station.state, null);
      expect(station.availableMechanicalBikes, null);
      expect(station.availableElectricBikes, null);
      expect(station.distanceKm, null);
      expect(station.rating, 5);
    });

    test('should parse closed station state', () {
      final jsonData = {
        'id': '3',
        'estado': 'CERRADA',
      };

      final station = BicycleStationDetails.fromJson(jsonData);

      expect(station.state, BicycleStationState.closed);
    });

    test('should handle invalid state string', () {
      final jsonData = {
        'id': '4',
        'estado': 'UNKNOWN',
      };

      final station = BicycleStationDetails.fromJson(jsonData);

      expect(station.state, null);
    });

    test('should calculate availableBikes when only mechanical bikes are present', () {
      final jsonData = {
        'id': '5',
        'bicisMecanicasDisponibles': 10,
        'bicisElectricasDisponibles': null,
      };

      final station = BicycleStationDetails.fromJson(jsonData);

      expect(station.availableMechanicalBikes, 10);
      expect(station.availableElectricBikes, null);
    });

    test('should calculate availableBikes when only electric bikes are present', () {
      final jsonData = {
        'id': '6',
        'bicisMecanicasDisponibles': null,
        'bicisElectricasDisponibles': 5,
      };

      final station = BicycleStationDetails.fromJson(jsonData);

      expect(station.availableMechanicalBikes, null);
      expect(station.availableElectricBikes, 5);
    });

    test('should handle coordinates as integers', () {
      final jsonData = {
        'id': '7',
        'coordenadas': {'latitude': 41, 'longitude': 2},
      };

      final station = BicycleStationDetails.fromJson(jsonData);

      expect(station.latitude, 41.0);
      expect(station.longitude, 2.0);
    });

    test('should handle distanceKm as integer', () {
      final jsonData = {
        'id': '8',
        'distanciaKm': 2,
      };

      final station = BicycleStationDetails.fromJson(jsonData);

      expect(station.distanceKm, 2.0);
    });

    test('should parse with minimal data (only id)', () {
      final jsonData = {
        'id': '9',
      };

      final station = BicycleStationDetails.fromJson(jsonData);

      expect(station.id, '9');
      expect(station.name, null);
      expect(station.rating, 5);
    });

    test('should ignore extra fields in JSON', () {
      final jsonData = {
        'id': '10',
        'nombre': 'Station 10',
        'extraField': 'should be ignored',
        'anotherExtra': 123,
      };

      final station = BicycleStationDetails.fromJson(jsonData);

      expect(station.id, '10');
      expect(station.name, 'Station 10');
    });
  });

  group('EVStationDetails.fromJson', () {
    test('should parse valid JSON data with connectors', () {
      final jsonData = {
        'id': 'EV1',
        'name': 'EV Station 1',
        'address': 'EV Address 1',
        'coordinates': {'latitude': 41.3851, 'longitude': 2.1734},
        'isSuperFast': true,
        'accessType': 'public',
        'distance': 1.5,
        'connectors': [
          {
            'type': 'mennekes',
            'powerKw': 50.0,
            'status': 'available',
          },
          {
            'type': 'chademo',
            'powerKw': 100.0,
            'status': 'occupied',
          },
        ],
      };

      final station = EVStationDetails.fromJson(jsonData);

      expect(station.id, 'EV1');
      expect(station.name, 'EV Station 1');
      expect(station.address, 'EV Address 1');
      expect(station.latitude, 41.3851);
      expect(station.longitude, 2.1734);
      expect(station.isSuperFast, true);
      expect(station.accessType, 'public');
      expect(station.distanceKm, 1.5);
      expect(station.rating, 5);
      expect(station.connectors?.length, 2);
      expect(station.totalSlots, 2);
      expect(station.connectors?[0].connectionType, ConnectionType.mennekes);
      expect(station.connectors?[0].powerKw, 50.0);
      expect(station.connectors?[0].status, ConnectorStatus.available);
      expect(station.connectors?[1].connectionType, ConnectionType.chademo);
      expect(station.connectors?[1].powerKw, 100.0);
      expect(station.connectors?[1].status, ConnectorStatus.occupied);
    });

    test('should handle null values and no connectors', () {
      final jsonData = {
        'id': 'EV2',
        'name': null,
        'address': null,
        'coordinates': null,
        'isSuperFast': null,
        'accessType': null,
        'distance': null,
        'connectors': null,
      };

      final station = EVStationDetails.fromJson(jsonData);

      expect(station.id, 'EV2');
      expect(station.name, null);
      expect(station.address, null);
      expect(station.latitude, null);
      expect(station.longitude, null);
      expect(station.isSuperFast, null);
      expect(station.accessType, null);
      expect(station.distanceKm, null);
      expect(station.connectors, null);
      expect(station.totalSlots, null);
      expect(station.availableSlots, 0);
      expect(station.rating, 5);
    });

    test('should handle invalid connector type', () {
      final jsonData = {
        'id': 'EV3',
        'connectors': [
          {
            'type': 'invalid_type',
            'powerKw': 50.0,
            'status': 'available',
          },
        ],
      };

      final station = EVStationDetails.fromJson(jsonData);

      expect(station.connectors?[0].powerKw, 50.0);
      expect(station.connectors?[0].status, ConnectorStatus.available);
    });

    test('should handle invalid connector status', () {
      final jsonData = {
        'id': 'EV4',
        'connectors': [
          {
            'type': 'mennekes',
            'powerKw': 50.0,
            'status': 'invalid_status',
          },
        ],
      };

      final station = EVStationDetails.fromJson(jsonData);

      expect(station.connectors?[0].connectionType, ConnectionType.mennekes);
      expect(station.connectors?[0].powerKw, 50.0);
    });

    test('should calculate availableSlots correctly', () {
      final jsonData = {
        'id': 'EV5',
        'connectors': [
          {'type': 'mennekes', 'powerKw': 50.0, 'status': 'available'},
          {'type': 'chademo', 'powerKw': 100.0, 'status': 'occupied'},
          {'type': 'css2', 'powerKw': 22.0, 'status': 'unavailable'},
        ],
      };

      final station = EVStationDetails.fromJson(jsonData);

      expect(station.totalSlots, 3);
    });

    test('should handle coordinates as integers', () {
      final jsonData = {
        'id': 'EV6',
        'coordinates': {'latitude': 41, 'longitude': 2},
      };

      final station = EVStationDetails.fromJson(jsonData);

      expect(station.latitude, 41.0);
      expect(station.longitude, 2.0);
    });

    test('should handle distance as integer', () {
      final jsonData = {
        'id': 'EV7',
        'distance': 2,
      };

      final station = EVStationDetails.fromJson(jsonData);

      expect(station.distanceKm, 2.0);
    });

    test('should parse with minimal data (only id)', () {
      final jsonData = {
        'id': 'EV8',
      };

      final station = EVStationDetails.fromJson(jsonData);

      expect(station.id, 'EV8');
      expect(station.name, null);
      expect(station.connectors, null);
      expect(station.rating, 5);
    });
  });
}