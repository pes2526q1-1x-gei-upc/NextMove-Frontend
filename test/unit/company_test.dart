import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/company.dart';

void main() {
  group('Company', () {
    test('constructor should create company with required fields', () {
      final company = Company(
        name: 'Test Company',
        email: 'test@company.com',
        url: 'https://test.com',
      );

      expect(company.name, 'Test Company');
      expect(company.email, 'test@company.com');
      expect(company.url, 'https://test.com');
      expect(company.description, isNull);
      expect(company.logoUrl, isNull);
      expect(company.location, isNull);
    });

    test('constructor should create company with all fields', () {
      final location = LatLng(41.3851, 2.1734);
      final company = Company(
        name: 'Test Company',
        email: 'test@company.com',
        url: 'https://test.com',
        description: 'A test company',
        logoUrl: 'https://test.com/logo.png',
        location: location,
      );

      expect(company.name, 'Test Company');
      expect(company.email, 'test@company.com');
      expect(company.url, 'https://test.com');
      expect(company.description, 'A test company');
      expect(company.logoUrl, 'https://test.com/logo.png');
      expect(company.location, location);
    });

    group('fromJson', () {
      test('should parse JSON with all fields', () {
        final json = {
          'name': 'Test Company',
          'email': 'test@company.com',
          'url': 'https://test.com',
          'description': 'A test company',
          'logo_url': 'https://test.com/logo.png',
          'location': {
            'latitude': 41.3851,
            'longitude': 2.1734,
          },
        };

        final company = Company.fromJson(json);

        expect(company.name, 'Test Company');
        expect(company.email, 'test@company.com');
        expect(company.url, 'https://test.com');
        expect(company.description, 'A test company');
        expect(company.logoUrl, 'https://test.com/logo.png');
        expect(company.location, LatLng(41.3851, 2.1734));
      });

      test('should parse JSON with null optional fields', () {
        final json = {
          'name': 'Test Company',
          'email': null,
          'url': null,
          'description': null,
          'logo_url': null,
          'location': null,
        };

        final company = Company.fromJson(json);

        expect(company.name, 'Test Company');
        expect(company.email, isNull);
        expect(company.url, isNull);
        expect(company.description, isNull);
        expect(company.logoUrl, isNull);
        expect(company.location, isNull);
      });

      test('should parse JSON without optional fields', () {
        final json = {
          'name': 'Test Company',
        };

        final company = Company.fromJson(json);

        expect(company.name, 'Test Company');
        expect(company.email, isNull);
        expect(company.url, isNull);
        expect(company.description, isNull);
        expect(company.logoUrl, isNull);
        expect(company.location, isNull);
      });
    });
  });
}