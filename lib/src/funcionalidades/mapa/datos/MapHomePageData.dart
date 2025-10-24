//import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/dominio/station_model.dart';
import 'dart:async';

Future<QueryResult> getGraphQLQuery(QueryOptions options) async {
  GraphQLClient client = GraphQLConfig.getClient();
  print("GraphQL client obtained");
  late QueryResult result;
  try {
     result = await client.query(options).timeout(
      Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('GraphQL query timeout after 10 seconds');
      },
    );
       

  } catch (e) {
    print('Exception caught in getGraphQLQuery: $e');
    rethrow;
    
  }

  return result;

}

Future<List<StationModel>> DBgetAllStations() async {
  print("entra en DBgetAllStations");
    final QueryOptions options = QueryOptions(
      
      document: gql(GraphQLQueries.getAllStationsQuery),
    );
    print("sale de las options");
    late QueryResult result;
  try{
     result = await getGraphQLQuery( options);
  } catch(e){
    print('Exception caught in DBgetAllStations: $e');
    rethrow;
  }
  print("sale de getGraphQLQuery");
    print("sale de getGraphQLQuery");

    if(result.data != null) {
      print("data received from the server");
    }
    else{
      print("no data received from the server");
    
    }
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