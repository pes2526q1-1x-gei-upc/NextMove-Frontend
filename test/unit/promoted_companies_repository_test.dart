import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/company.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/dataproviders/promoted_companies_provider.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/repositories/promoted_companies_repository.dart';

class MockPromotedCompaniesProvider extends Mock
    implements PromotedCompaniesProvider {}

void main() {
  late MockPromotedCompaniesProvider mockProvider;
  late PromotedCompaniesRepository repository;

  setUp(() {
    mockProvider = MockPromotedCompaniesProvider();
    repository = PromotedCompaniesRepository(
      promotedCompaniesProvider: mockProvider,
    );
  });

  tearDown(() {
    reset(mockProvider);
  });

  group('PromotedCompaniesRepository', () {
    test(
      'should return list of companies on successful data retrieval',
      () async {
        final mockData = [
          {
            'location': {'latitude': 41.3851, 'longitude': 2.1734},
            'name': 'Company A',
            'description': 'Desc A',
            'email': 'companya@test.com',
            'url': 'https://companya.com',
            'logo_url': 'https://companya.com/logo.png',
          },
          {
            'location': {'latitude': 40.4168, 'longitude': -3.7038},
            'name': 'Company B',
            'description': 'Desc B',
            'email': 'companyb@test.com',
            'url': 'https://companyb.com',
            'logo_url': 'https://companyb.com/logo.png',
          },
        ];
        when(
          () => mockProvider.getPromotedCompanies(),
        ).thenAnswer((_) async => mockData);

        final result = await repository.getPromotedCompanies();

        expect(result, isA<Right<Failure, List<Company>>>());
        final companies = result.getOrElse(() => []);
        expect(companies.length, 2);
        expect(companies[0].name, 'Company A');
        expect(companies[0].location, LatLng(41.3851, 2.1734));
        expect(companies[0].description, 'Desc A');
        expect(companies[1].name, 'Company B');
        expect(companies[1].location, LatLng(40.4168, -3.7038));
        expect(companies[1].description, 'Desc B');
      },
    );

    test('should return empty list when provider returns null', () async {
      when(
        () => mockProvider.getPromotedCompanies(),
      ).thenAnswer((_) async => null);

      final result = await repository.getPromotedCompanies();

      expect(result, isA<Right<Failure, List<Company>>>());
      expect(result.getOrElse(() => []), <Company>[]);
    });

    test('should return ServerFailure on ServerException', () async {
      const exceptionMessage = 'Server error';
      when(
        () => mockProvider.getPromotedCompanies(),
      ).thenThrow(ServerException(exceptionMessage));

      final result = await repository.getPromotedCompanies();

      expect(result, isA<Left<Failure, List<Company>>>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, exceptionMessage);
    });

    test('should return ConnectionFailure on ConnectionException', () async {
      when(
        () => mockProvider.getPromotedCompanies(),
      ).thenThrow(ConnectionException());

      final result = await repository.getPromotedCompanies();

      expect(result, isA<Left<Failure, List<Company>>>());
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ConnectionFailure>());
      expect((failure as ConnectionFailure).message, 'Sin conexión a internet');
    });

    test('should return UnknownFailure on other exceptions', () async {
      when(
        () => mockProvider.getPromotedCompanies(),
      ).thenThrow(Exception('Unknown error'));

      final result = await repository.getPromotedCompanies();

      expect(result, isA<Left<Failure, List<Company>>>());
      expect(result.fold((l) => l, (r) => null), isA<UnknownFailure>());
    });

    test('should return empty list when provider returns empty list', () async {
      when(
        () => mockProvider.getPromotedCompanies(),
      ).thenAnswer((_) async => []);

      final result = await repository.getPromotedCompanies();

      expect(result, isA<Right<Failure, List<Company>>>());
      expect(result.getOrElse(() => []), <Company>[]);
    });

    test('should return UnknownFailure when data is malformed', () async {
      final mockData = [
        {
          'ubicacion': {'latitude': 41.3851, 'longitude': 2.1734},
          'descripcion': 'Desc A',
          'id': 1,
          // missing 'nombre'
        },
      ];
      when(
        () => mockProvider.getPromotedCompanies(),
      ).thenAnswer((_) async => mockData);

      final result = await repository.getPromotedCompanies();

      expect(result, isA<Left<Failure, List<Company>>>());
      expect(result.fold((l) => l, (r) => null), isA<UnknownFailure>());
    });

    test('should handle extra fields', () async {
      final mockData = [
        {
          'location': {'latitude': 41.3851, 'longitude': 2.1734},
          'name': 'Company A',
          'description': 'Desc A',
          'email': 'companya@test.com',
          'url': 'https://companya.com',
          'logo_url': 'https://companya.com/logo.png',
          'extra': 'value',
        },
      ];
      when(
        () => mockProvider.getPromotedCompanies(),
      ).thenAnswer((_) async => mockData);

      final result = await repository.getPromotedCompanies();

      expect(result, isA<Right<Failure, List<Company>>>());
      final companies = result.getOrElse(() => []);
      expect(companies.length, 1);
      expect(companies[0].name, 'Company A');
      expect(companies[0].location, LatLng(41.3851, 2.1734));
      expect(companies[0].description, 'Desc A');
    });
  });
}
