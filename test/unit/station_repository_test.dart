import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/dataproviders/station_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/repositories/station_repository.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

class MockStationRemoteDataProvider extends Mock
    implements StationRemoteDataProvider {}

void main() {
  late MockStationRemoteDataProvider mockProvider;
  late StationRepository repository;

  setUpAll(() {
    registerFallbackValue(StationType.bicycle);
  });

  setUp(() {
    mockProvider = MockStationRemoteDataProvider();
    repository = StationRepository(stationRemoteDataProvider: mockProvider);
  });

  tearDown(() {
    reset(mockProvider);
  });

  test('getAllNearbyBicycleStationDetails returns Right on success', () async {
    final stations = [BicycleStationDetails(id: '1', availableSlots: 5)];
    when(() => mockProvider.getAllNearbyBicycleStationDetails(any(), any()))
        .thenAnswer((_) async => stations);

    final result =
        await repository.getAllNearbyBicycleStationDetails(1.0, 2.0);

    expect(result, isA<Right<Failure, List<BicycleStationDetails>?>>());
    expect(result.getOrElse(() => []), stations);
  });

  test('getAllNearbyBicycleStationDetails returns failure on ServerException',
      () async {
    when(() => mockProvider.getAllNearbyBicycleStationDetails(any(), any()))
        .thenThrow(const ServerException('fail'));

    final result =
        await repository.getAllNearbyBicycleStationDetails(1.0, 2.0);

    expect(result, isA<Left<Failure, List<BicycleStationDetails>?>>());
    expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
  });

  test('getAllEVStationDetails throws UnknownFailure on unexpected error',
      () async {
    when(() => mockProvider.getAllEVStationDetails())
        .thenThrow(StateError('boom'));

    expect(
      () => repository.getAllEVStationDetails(),
      throwsA(isA<UnknownFailure>()),
    );
  });

  test('setStationFavoriteStatus returns Right on success', () async {
    when(() => mockProvider.setStationFavoriteStatus(any(), any(), any()))
        .thenAnswer((_) async {});

    final result = await repository.setStationFavoriteStatus(
      'station-1',
      StationType.bicycle,
      true,
    );

    expect(result.isRight(), isTrue);
  });

  test('getFavBikeStationIds returns ConnectionFailure on ConnectionException',
      () async {
    when(() => mockProvider.getFavBikeStationIds())
        .thenThrow(ConnectionException());

    final result = await repository.getFavBikeStationIds();

    expect(result, isA<Left<Failure, List<String>>>());
    expect(result.fold((l) => l, (r) => null), isA<ConnectionFailure>());
  });
}
