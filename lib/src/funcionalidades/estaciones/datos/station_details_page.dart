import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/bicycle_station_details.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/ev_station_details.dart';

Future<QueryResult> getGraphQLQuery(String query, QueryOptions options) async {
  // OJO porque ahora coge el valor del notifier retornado, no el notifier!
  GraphQLClient client = GraphQLConfig.initializeClient().value;
  final QueryResult result = await client.query(options);

  if (result.hasException) {
    throw Exception('Error en query: ${result.exception.toString()}');
  }

  return result;
}

Future<BicycleStationDetails?> DBgetBicycleStationDetails(String stationID) async {
  final QueryOptions options = QueryOptions(
    document: gql(GraphQLQueries.getBicycleStationDetailsQuery),
    variables: {'stationID': stationID},
  );

  final QueryResult result = await getGraphQLQuery(GraphQLQueries.getBicycleStationDetailsQuery, options);

  print('Full GraphQL response for stationID $stationID: ${result.data}');
  if (result.hasException) {
    print('GraphQL Exception for stationID $stationID: ${result.exception.toString()}');
    throw Exception('Error en query: ${result.exception.toString()}');
  }

  final data = result.data?['getEstacionDeBicing'];
  print('getEstacionDeBicing data for stationID $stationID: $data');

  if (data != null) {
    return BicycleStationDetails.fromJson(data);
  }

  return null;
}

Future<List<BicycleStationDetails>?> DBgetAllBicycleStationDetails() async {
  final QueryOptions options = QueryOptions(
    document: gql(GraphQLQueries.getAllBicycleStationsQuery),
  );

  final QueryResult result = await getGraphQLQuery(GraphQLQueries.getAllBicycleStationsQuery, options);

  if (result.hasException) {
    print('GraphQL Exception: ${result.exception.toString()}');
    throw Exception('Error en query: ${result.exception.toString()}');
  }

  final data = result.data?['getEstacionesDeBicing'];
  print('getEstacionesDeBicing data: $data');

  if (data != null) {
    return (data as List)
        .map((item) => BicycleStationDetails.fromJson(item))
        .toList();
  }

  return null;
}

Future<List<BicycleStationDetails>?> DBgetAllNearbyBicycleStationDetails(double latitude, double longitude) async {
  final QueryOptions options = QueryOptions(
    document: gql(GraphQLQueries.getAllNearbyBicycleStationsQuery),
    variables: {
      "latitude": latitude,
      "longitude": longitude,
    }
  );

  final QueryResult result = await getGraphQLQuery(GraphQLQueries.getAllNearbyBicycleStationsQuery, options);

  if (result.hasException) {
    throw Exception('Error en query: ${result.exception.toString()}');
  }

  final data = result.data?['getEstacionesDeBicingCercanas'];
  if (data != null) {
    return (data as List)
        .map((item) => BicycleStationDetails.fromJson(item))
        .toList();
  }
  
  return null;
}

Future<EVStationDetails?> DBgetEVStationDetails(String stationID) async {
  final QueryOptions options = QueryOptions(
    document: gql(GraphQLQueries.getEVStationDetailsQuery),
    variables: {'stationID': stationID},
  );

  final QueryResult result = await getGraphQLQuery(GraphQLQueries.getEVStationDetailsQuery, options);
  
  if (result.hasException) {
    throw Exception('Error en query: ${result.exception.toString()}');
  }

  final data = result.data?['station'];
  print(data);
  
  if (data != null) {
    return EVStationDetails.fromJson(data);
  }
  
  return null;
}

Future<List<EVStationDetails>?> DBgetAllEVStationDetails() async {
  final QueryOptions options = QueryOptions(
    document: gql(GraphQLQueries.getAllEVStationsQuery),
  );

  final QueryResult result = await getGraphQLQuery(GraphQLQueries.getAllEVStationsQuery, options);

  if (result.hasException) {
    throw Exception('Error en query: ${result.exception.toString()}');
  }

  final data = result.data?['stations']['stations'];
  if (data != null) {
    return (data as List)
        .map((item) {
          final station = EVStationDetails.fromJson(item);
          print('Raw EV station item: $station');
          return station;
        })
        .toList();
  }
  
  return null;
}

Future<List<EVStationDetails>?> DBgetAllNearbyEVStationDetails(double latitude, double longitude) async {
  final QueryOptions options = QueryOptions(
    document: gql(GraphQLQueries.getAllNearbyEVStationsQuery),
    variables: {
      "location": {
        "coordinates": {
          "latitude": latitude,
          "longitude": longitude,
        },
        "radiusKm": 100
      }
    }
  );

  final QueryResult result = await getGraphQLQuery(GraphQLQueries.getAllNearbyEVStationsQuery, options);

  if (result.hasException) {
    throw Exception('Error en query: ${result.exception.toString()}');
  }
    print('Raw GraphQL response: ${result.data}');

  final data = result.data?['nearbyStations'];
  if (data != null) {
    return (data as List)
        .map((item) => EVStationDetails.fromJson(item))
        .toList();
  }

  return null;
}