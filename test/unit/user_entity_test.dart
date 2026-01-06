import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    group('fromRawData', () {
      test('should parse valid JSON data correctly', () {
        final jsonData = {
          'email': 'test@example.com',
          'nickname': 'testuser',
          'name': 'Test User',
          'birthDate': '1990-01-01',
          'createdAt': '2020-01-01T00:00:00Z',
          'phoneNumber': '123456789',
          'preferredLanguage': 'ESP',
          'bioDescription': 'Test bio',
          'preferredMode': 'BIKE',
          'photo': 'https://example.com/photo.jpg',
          'regWithGoogle': false,
        };

        final user = UserEntity.fromRawData(jsonData);

        expect(user.email, 'test@example.com');
        expect(user.apodo, 'testuser');
        expect(user.nombreCompleto, 'Test User');
        expect(user.fechaNacimiento, DateTime.parse('1990-01-01'));
        expect(user.numeroTelefono, 123456789);
        expect(user.idiomaPreferido, 'Español');
        expect(user.descripcion, 'Test bio');
        expect(user.modoPreferido, 'Bicicleta');
        expect(user.photo, 'https://example.com/photo.jpg');
        expect(user.regWithGoogle, false);
      });

      test('should handle null values correctly', () {
        final jsonData = {
          'email': 'test@example.com',
          'nickname': null,
          'name': null,
          'birthDate': null,
          'createdAt': null,
          'phoneNumber': null,
          'preferredLanguage': null,
          'bioDescription': null,
          'preferredMode': null,
          'photo': null,
        };

        final user = UserEntity.fromRawData(jsonData);

        expect(user.email, 'test@example.com');
        expect(user.apodo, 'Usuario');
        expect(user.nombreCompleto, 'Nombre no disponible');
        expect(user.numeroTelefono, 0);
        expect(user.idiomaPreferido, 'Español');
        expect(user.descripcion, '');
        expect(user.modoPreferido, 'Coche');
        expect(user.photo, '');
      });

      test('should parse statistics correctly', () {
        final jsonData = {
          'email': 'test@example.com',
          'nickname': 'testuser',
          'name': 'Test User',
          'birthDate': '1990-01-01',
          'createdAt': '2020-01-01T00:00:00Z',
          'phoneNumber': '123456789',
          'preferredLanguage': 'ESP',
          'bioDescription': 'Test bio',
          'preferredMode': 'BIKE',
          'photo': 'https://example.com/photo.jpg',
          'statistics': {
            'num_rutas': 10,
            'km_recorridos': 100.5,
            'elevacion_positiva': 500.0,
            'calorias_quemadas': 2000.0,
            'co2_ahorrado': 50.0,
            'num_retos_participados': 5,
            'num_retos_completados': 3,
            'puntos_totales': 1000,
          },
        };

        final user = UserEntity.fromRawData(jsonData);

        expect(user.statistics, isNotNull);
        expect(user.statistics!.totalRoutes, 10);
        expect(user.statistics!.distance, 100.5);
        expect(user.statistics!.elevationGain, 500.0);
        expect(user.statistics!.caloriesBurned, 2000.0);
        expect(user.statistics!.co2Saved, 50.0);
        expect(user.statistics!.challengesParticipated, 5);
        expect(user.statistics!.challengesCompleted, 3);
        expect(user.statistics!.points, 1000);
      });

      test('should map language codes correctly', () {
        final testCases = [
          {'lang': 'es', 'expected': 'Español'},
          {'lang': 'ESP', 'expected': 'Español'},
          {'lang': 'en', 'expected': 'English'},
          {'lang': 'ENG', 'expected': 'English'},
          {'lang': 'ca', 'expected': 'Català'},
          {'lang': 'CAT', 'expected': 'Català'},
          {'lang': 'unknown', 'expected': 'Español'},
        ];

        for (final testCase in testCases) {
          final jsonData = {
            'email': 'test@example.com',
            'nickname': 'testuser',
            'name': 'Test User',
            'birthDate': '1990-01-01',
            'createdAt': '2020-01-01T00:00:00Z',
            'phoneNumber': '123456789',
            'preferredLanguage': testCase['lang'],
            'bioDescription': '',
            'preferredMode': 'BIKE',
            'photo': '',
          };

          final user = UserEntity.fromRawData(jsonData);
          expect(user.idiomaPreferido, testCase['expected']);
        }
      });

      test('should map preferred mode correctly', () {
        final testCases = [
          {'mode': 'BIKE', 'expected': 'Bicicleta'},
          {'mode': 'CAR', 'expected': 'Coche'},
          {'mode': 'unknown', 'expected': 'Coche'},
        ];

        for (final testCase in testCases) {
          final jsonData = {
            'email': 'test@example.com',
            'nickname': 'testuser',
            'name': 'Test User',
            'birthDate': '1990-01-01',
            'createdAt': '2020-01-01T00:00:00Z',
            'phoneNumber': '123456789',
            'preferredLanguage': 'ESP',
            'bioDescription': '',
            'preferredMode': testCase['mode'],
            'photo': '',
          };

          final user = UserEntity.fromRawData(jsonData);
          expect(user.modoPreferido, testCase['expected']);
        }
      });
    });

    group('toMap', () {
      test('should convert entity to map correctly', () {
        final user = UserEntity(
          email: 'test@example.com',
          apodo: 'testuser',
          nombreCompleto: 'Test User',
          fechaNacimiento: DateTime.parse('1990-01-01'),
          fechaRegistro: DateTime.parse('2020-01-01T00:00:00Z'),
          numeroTelefono: 123456789,
          idiomaPreferido: 'Español',
          descripcion: 'Test bio',
          modoPreferido: 'Bicicleta',
          photo: 'https://example.com/photo.jpg',
          regWithGoogle: false,
        );

        final map = user.toMap();

        expect(map['email'], 'test@example.com');
        expect(map['nickname'], 'testuser');
        expect(map['name'], 'Test User');
        expect(map['birthDate'], '1990-01-01');
        expect(map['phoneNumber'], '123456789');
        expect(map['preferredLanguage'], 'ESP');
        expect(map['bioDescription'], 'Test bio');
        expect(map['preferredMode'], 'BIKE');
        expect(map['photo'], 'https://example.com/photo.jpg');
        expect(map['regWithGoogle'], false);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = UserEntity(
          email: 'test@example.com',
          apodo: 'testuser',
          nombreCompleto: 'Test User',
          fechaNacimiento: DateTime.parse('1990-01-01'),
          fechaRegistro: DateTime.parse('2020-01-01T00:00:00Z'),
          numeroTelefono: 123456789,
          idiomaPreferido: 'Español',
          descripcion: 'Test bio',
          modoPreferido: 'Bicicleta',
          photo: 'https://example.com/photo.jpg',
        );

        final updated = original.copyWith(
          apodo: 'newuser',
          descripcion: 'New bio',
        );

        expect(updated.apodo, 'newuser');
        expect(updated.descripcion, 'New bio');
        expect(updated.email, original.email);
        expect(updated.nombreCompleto, original.nombreCompleto);
      });
    });
  });
}

