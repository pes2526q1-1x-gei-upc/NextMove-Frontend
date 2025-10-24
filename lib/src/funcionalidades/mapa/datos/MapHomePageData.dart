//import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/dominio/station_model.dart';
import 'dart:async';

Future<QueryResult> getGraphQLQuery(QueryOptions options) async {
  GraphQLClient client = GraphQLConfig.getClient();
  final QueryResult result;
  
     result = await client.query(options).timeout(
      Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('GraphQL query timeout after 10 seconds');
      },
    ); 

  return result;

}

Future<List<StationModel>> DBgetAllStations() async {
    final QueryOptions options = QueryOptions(
      
      document: gql(GraphQLQueries.getAllStationsQuery),
    );
    final QueryResult result;
  
     result = await getGraphQLQuery( options);
  
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