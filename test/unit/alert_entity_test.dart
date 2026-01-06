import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/alerts/dominio/alert_entity.dart';

void main() {
  group('StationAlert', () {
    group('fromJson', () {
      test('should parse valid JSON data correctly', () {
        final jsonData = {
          'id': 'alert-1',
          'userEmail': 'user@example.com',
          'stationId': 'station-1',
          'horas': ['08:00', '18:00'],
          'diasSemana': [1, 3, 5],
          'activa': true,
          'createdAt': '2022-01-01T00:00:00Z',
          'updatedAt': '2022-01-02T00:00:00Z',
          'stationNombre': 'Test Station',
          'stationDireccion': 'Test Address',
        };

        final alert = StationAlert.fromJson(jsonData);

        expect(alert.id, 'alert-1');
        expect(alert.userEmail, 'user@example.com');
        expect(alert.stationId, 'station-1');
        expect(alert.horas.length, 2);
        expect(alert.horas[0], '08:00');
        expect(alert.diasSemana.length, 3);
        expect(alert.diasSemana[0], 1);
        expect(alert.activa, true);
        expect(alert.stationNombre, 'Test Station');
        expect(alert.stationDireccion, 'Test Address');
      });

      test('should handle null values correctly', () {
        final jsonData = {
          'id': 'alert-2',
          'userEmail': 'user@example.com',
          'stationId': 'station-2',
          'horas': [],
          'diasSemana': [],
          'activa': false,
          'createdAt': '2022-01-01T00:00:00Z',
          'updatedAt': '2022-01-02T00:00:00Z',
        };

        final alert = StationAlert.fromJson(jsonData);

        expect(alert.horas, isEmpty);
        expect(alert.diasSemana, isEmpty);
        expect(alert.activa, false);
        expect(alert.stationNombre, isNull);
        expect(alert.stationDireccion, isNull);
      });

      test('should handle integer id', () {
        final jsonData = {
          'id': 123,
          'userEmail': 'user@example.com',
          'stationId': 'station-3',
          'horas': ['09:00'],
          'diasSemana': [0],
          'activa': true,
          'createdAt': '2022-01-01T00:00:00Z',
          'updatedAt': '2022-01-02T00:00:00Z',
        };

        final alert = StationAlert.fromJson(jsonData);

        expect(alert.id, '123');
      });

      test('should handle string diasSemana', () {
        final jsonData = {
          'id': 'alert-4',
          'userEmail': 'user@example.com',
          'stationId': 'station-4',
          'horas': ['10:00'],
          'diasSemana': ['1', '2', '3'],
          'activa': true,
          'createdAt': '2022-01-01T00:00:00Z',
          'updatedAt': '2022-01-02T00:00:00Z',
        };

        final alert = StationAlert.fromJson(jsonData);

        expect(alert.diasSemana.length, 3);
        expect(alert.diasSemana[0], 1);
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly', () {
        final alert = StationAlert(
          id: 'alert-1',
          userEmail: 'user@example.com',
          stationId: 'station-1',
          horas: ['08:00', '18:00'],
          diasSemana: [1, 3, 5],
          activa: true,
          createdAt: DateTime.parse('2022-01-01T00:00:00Z'),
          updatedAt: DateTime.parse('2022-01-02T00:00:00Z'),
          stationNombre: 'Test Station',
          stationDireccion: 'Test Address',
        );

        final json = alert.toJson();

        expect(json['id'], 'alert-1');
        expect(json['userEmail'], 'user@example.com');
        expect(json['stationId'], 'station-1');
        expect(json['horas'], ['08:00', '18:00']);
        expect(json['diasSemana'], [1, 3, 5]);
        expect(json['activa'], true);
        expect(json['stationNombre'], 'Test Station');
        expect(json['stationDireccion'], 'Test Address');
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = StationAlert(
          id: 'alert-1',
          userEmail: 'user@example.com',
          stationId: 'station-1',
          horas: ['08:00'],
          diasSemana: [1],
          activa: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final updated = original.copyWith(
          activa: false,
          horas: ['09:00', '17:00'],
        );

        expect(updated.activa, false);
        expect(updated.horas.length, 2);
        expect(updated.id, original.id);
        expect(updated.stationId, original.stationId);
      });
    });

    group('getDiaNombre', () {
      test('should return correct day names', () {
        expect(StationAlert.getDiaNombre(0), 'Lunes');
        expect(StationAlert.getDiaNombre(1), 'Martes');
        expect(StationAlert.getDiaNombre(2), 'Miércoles');
        expect(StationAlert.getDiaNombre(3), 'Jueves');
        expect(StationAlert.getDiaNombre(4), 'Viernes');
        expect(StationAlert.getDiaNombre(5), 'Sábado');
        expect(StationAlert.getDiaNombre(6), 'Domingo');
      });
    });

    group('diasSemanaNombres', () {
      test('should return list of day names', () {
        final alert = StationAlert(
          id: 'alert-1',
          userEmail: 'user@example.com',
          stationId: 'station-1',
          horas: ['08:00'],
          diasSemana: [0, 2, 4],
          activa: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final nombres = alert.diasSemanaNombres;

        expect(nombres.length, 3);
        expect(nombres[0], 'Lunes');
        expect(nombres[1], 'Miércoles');
        expect(nombres[2], 'Viernes');
      });
    });
  });
}

