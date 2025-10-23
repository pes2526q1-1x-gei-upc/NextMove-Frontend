import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/dominio/station_model.dart';

Future<QueryResult> getGraphQLQuery(String query, QueryOptions options) async {
  GraphQLClient client = GraphQLConfig.getClient();
  final QueryResult result = await client.query(options);

  if (result.hasException) {
    throw Exception('Error en query: ${result.exception.toString()}');
  }

  return result;
}

Future<List<StationModel>> DBgetAllStations() async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getAllStationsQuery),
    );

    final QueryResult result = await getGraphQLQuery(GraphQLQueries.getAllStationsCoordinatesQuery, options);

    if (result.hasException) {
      throw Exception('Failed to load stations: ${result.exception.toString()}');
    }

    final stationsData = result.data?['stations']['stations'] as List<dynamic>; 
    return stationsData.map((json) => StationModel.fromJson(json as Map<String, dynamic>)).toList(); //Esto es poco entendible, mejor lo puedo pasar a un bucle normal
    /*
    List<StationModel> stations = [];
    for (var json in stationsData) {
    stations.add(StationModel.fromJson(json as Map<String, dynamic>));
    } 
    return stations;
    */
  }