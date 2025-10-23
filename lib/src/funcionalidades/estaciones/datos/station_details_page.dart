import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/bicycle_station_details.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/ev_station_details.dart';

Future<QueryResult> getGraphQLQuery(String query, QueryOptions options) async {
  GraphQLClient client = GraphQLConfig.getClient();
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

  if (result.hasException) {
    throw Exception('Error en query: ${result.exception.toString()}');
  }

  final data = result.data?['getEstacionDeBicing'];
  print(data);

  if (data != null) {
    return BicycleStationDetails.fromJson(data);
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
