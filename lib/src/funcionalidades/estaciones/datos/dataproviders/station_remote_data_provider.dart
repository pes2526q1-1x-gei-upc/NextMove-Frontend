import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/dataproviders/auth_remote_data_provider.dart';

Future<QueryResult> getGraphQLQuery(String query, QueryOptions options) async {
  // OJO porque ahora coge el valor del notifier retornado, no el notifier!
  GraphQLClient client = GraphQLConfig.initializeClient().value;
  final QueryResult result = await client.query(options);

  if (result.hasException) {
    throw Exception('Error en query: ${result.exception.toString()}');
  }

  return result;
}

class StationRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

  Future<List<BicycleStationDetails>?> getAllNearbyBicycleStationDetails(
    double latitude,
    double longitude,
  ) async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getAllNearbyBicycleStationsQuery),
      variables: {
        "location": {
          "radiusKm": 100,
          "coordinates": {"latitude": latitude, "longitude": longitude},
        },
      },
    );

    final QueryResult result = await getGraphQLQuery(
      GraphQLQueries.getAllNearbyBicycleStationsQuery,
      options,
    );

    if (result.hasException) {
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    if (kDebugMode) {
      print(
        'getAllNearbyBicycleStationDetails result.data (from location $latitude, $longitude): ${result.data}',
      );
    }
    final data = result.data?['getEstacionesDeBicingCercanas'];
    if (data != null) {
      return (data as List)
          .map((item) => BicycleStationDetails.fromJson(item))
          .toList();
    }

    return null;
  }

  Future<List<EVStationDetails>?> getAllNearbyEVStationDetails(
    double latitude,
    double longitude,
  ) async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getAllNearbyEVStationsQuery),
      variables: {
        "location": {
          "coordinates": {"latitude": latitude, "longitude": longitude},
          "radiusKm": 100,
        },
      },
    );

    final QueryResult result = await getGraphQLQuery(
      GraphQLQueries.getAllNearbyEVStationsQuery,
      options,
    );

    if (result.hasException) {
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    if (kDebugMode) {
      print('getAllNearbyEVStationDetails result.data: ${result.data}');
    }
    final data = result.data?['nearbyStations'];
    if (data != null) {
      return (data as List)
          .map((item) => EVStationDetails.fromJson(item))
          .toList();
    }

    return null;
  }

  Future<List<BicycleStationDetails>?> getAllBicycleStationDetails() async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getAllBicycleStationsQuery),
    );

    final QueryResult result = await getGraphQLQuery(
      GraphQLQueries.getAllBicycleStationsQuery,
      options,
    );

    if (result.hasException) {
      if (kDebugMode) {
        print('GraphQL Exception: ${result.exception.toString()}');
      }
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    if (kDebugMode) {
      print('getAllBicycleStationDetails result.data: ${result.data}');
    }
    final data = result.data?['getEstacionesDeBicing'];

    if (data != null) {
      return (data as List)
          .map((item) => BicycleStationDetails.fromJson(item))
          .toList();
    }

    return null;
  }

  Future<List<EVStationDetails>?> getAllEVStationDetails() async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getAllEVStationsQuery),
    );

    final QueryResult result = await getGraphQLQuery(
      GraphQLQueries.getAllEVStationsQuery,
      options,
    );

    if (result.hasException) {
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    if (kDebugMode) {
      print('getAllEVStationDetails result.data: ${result.data}');
    }
    final data = result.data?['stations']['stations'];
    if (data != null) {
      return (data as List).map((item) {
        final station = EVStationDetails.fromJson(item);
        return station;
      }).toList();
    }

    return null;
  }

  Future<BicycleStationDetails> getBicycleStationDetails(
    String stationID,
  ) async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getBicycleStationDetailsQuery),
      variables: {'stationID': stationID},
    );

    final QueryResult result = await getGraphQLQuery(
      GraphQLQueries.getBicycleStationDetailsQuery,
      options,
    );

    if (result.hasException) {
      if (kDebugMode) {
        print(
          'GraphQL Exception for stationID $stationID: ${result.exception.toString()}',
        );
      }
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    final data = result.data?['getEstacionDeBicing'];

    if (data != null) {
      return BicycleStationDetails.fromJson(data);
    }

    throw ServerException('Station not found');
  }

  Future<EVStationDetails> getEVStationDetails(String stationID) async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getEVStationDetailsQuery),
      variables: {'stationID': stationID},
    );

    final QueryResult result = await getGraphQLQuery(
      GraphQLQueries.getEVStationDetailsQuery,
      options,
    );

    if (result.hasException) {
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    final data = result.data?['station'];

    if (data != null) {
      return EVStationDetails.fromJson(data);
    }

    throw ServerException('Station not found');
  }

  Future<List<StationDetails>> searchEvStations(String query) async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getStationsBySearchQuery),
      variables: {'query': query},
    );

    final QueryResult result = await getGraphQLQuery(
      GraphQLQueries.getStationsBySearchQuery,
      options,
    );

    if (result.hasException) {
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    if (kDebugMode) {
      print('searchEvStations result.data: ${result.data}');
    }
    final data = result.data?['stationsByAddress'];
    if (data != null) {
      return (data as List)
          .map((item) => EVStationDetails.fromJson(item) as StationDetails)
          .toList();
    }

    return [];
  }

  Future<void> setStationFavoriteStatus(
    String stationId,
    StationType stationType,
    bool isFavorite,
  ) async {
    if (kDebugMode) {
      print(
        'setStationFavoriteStatus called for stationId: $stationId, isFavorite: $isFavorite',
      );
    }
    String? authHeader = await AuthRemoteDataProvider().authHeader;
    if (kDebugMode) {
      print('Auth Header: $authHeader');
    }
    final MutationOptions options = MutationOptions(
      document: gql(
        isFavorite
            ? GraphQLQueries.addFavStation
            : GraphQLQueries.deleteFavStation,
      ),
      variables: {
        'stationId': stationId,
        'stationType': stationType == StationType.bicycle ? 'BIKE' : 'CAR',
      },
      context: Context().withEntry(
        HttpLinkHeaders(headers: {'Authorization': ?authHeader}),
      ),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      if (kDebugMode) {
        print(
          'GraphQL Exception in setStationFavoriteStatus for stationId $stationId: ${result.exception.toString()}',
        );
      }
      throw ServerException(
        'Error en mutation: ${result.exception.toString()}',
      );
    }
  }
}
