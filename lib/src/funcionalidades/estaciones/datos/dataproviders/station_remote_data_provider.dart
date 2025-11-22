import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

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
}
