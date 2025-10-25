//import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';  // Comentado, no lo necesitas

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/dominio/station_model.dart';
import 'dart:async';

Future<QueryResult> getGraphQLQuery(QueryOptions options) async {
  print("GraphQL client obtained");
  GraphQLClient client = GraphQLConfig.getClient();  // Mueve aquí si no está
  print("Client ready, starting query...");
  
  try {
    print("About to execute client.query...");
    final result = await client.query(options).timeout(
      Duration(seconds: 10),
      onTimeout: () {
        print("Timeout triggered!");  // ← Para ver si es timeout
        throw TimeoutException('GraphQL query timeout after 10 seconds');
      },
    );
    print("Query executed successfully, result obtained");  // ← Si llega aquí, OK
    return result;
  } catch (e) {
    print('Exception caught in getGraphQLQuery: $e');
    print('Exception type: ${e.runtimeType}');  // ← Tipo exacto del error
    print('Stack trace: ${StackTrace.current}');  // ← Stack para debug (corto)
    rethrow;
  }
}

Future<List<StationModel>> DBgetAllStations() async {
  print("entra en DBgetAllStations");
  print("Creating options and gql...");
  final QueryOptions options = QueryOptions(
    document: gql(GraphQLQueries.getAllStationsQuery),
  );
  print("sale de las options");
  print("gql parsed OK, calling getGraphQLQuery...");
  
  late QueryResult result;
  try {
    result = await getGraphQLQuery(options);
  } catch (e) {
    print('Exception caught in DBgetAllStations: $e');
    rethrow;  // O return [] para no crashear la app entera
  }
  print("sale de getGraphQLQuery");

  // Debug: Print full data (borra después)
  print("Full result.data: ${result.data}");
  
  if (result.data != null) {
    print("data received from the server");
  } else {
    print("no data received from the server");
    return [];  // Early return para evitar crash
  }
  
  if (result.hasException) {
    print("GraphQL exception details: ${result.exception?.toString()}");
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

Future<List<StationModel>> DBgetAllBikeStations() async {
    final QueryOptions options = QueryOptions(
      
      document: gql(GraphQLQueries.getBikeStationsQuery),
    );
    final QueryResult result;
  
     result = await getGraphQLQuery( options);
  
    if (result.hasException) {
      throw Exception('Failed to load bike stations: ${result.exception.toString()}');
    }

    final stationsData = result.data?['getEstacionesDeBicing']as List<dynamic>; 
    return stationsData.map((json) => StationModel.fromJsonBicing(json as Map<String, dynamic>)).toList(); 
  }