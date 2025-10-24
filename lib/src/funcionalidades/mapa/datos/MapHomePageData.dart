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

  // Null-safe chaining
  final Map<String, dynamic>? data = result.data;
  final dynamic stationsWrapper = data?['stations'];
  print("stationsWrapper: $stationsWrapper");  // Debug: ve si {stations: [...], total: X}
  
  if (stationsWrapper == null) {
    print("stations wrapper is null - check backend");
    return [];
  }
  
  final dynamic stationsListRaw = stationsWrapper['stations'];
  final int total = stationsWrapper['total'] ?? 0;
  print("Total from backend: $total");
  
  if (stationsListRaw == null) {
    print("stations list is null - returning empty");
    return [];
  }
  
  // Chequea que sea List
  if (stationsListRaw is! List) {
    print("stations list is not a List (got ${stationsListRaw.runtimeType}) - returning empty");
    return [];
  }
  
  final List<dynamic> stationsData = stationsListRaw as List<dynamic>;
  print("stationsData length: ${stationsData.length}");  // ← Clave para debug
  
  if (stationsData.isEmpty) {
    print("stationsData is empty - returning empty list");
    return [];
  }

  // Bucle legible para parse (como sugeriste)
  List<StationModel> stations = [];
  for (var json in stationsData) {
    try {
      if (json is Map<String, dynamic>) {
        stations.add(StationModel.fromJson(json));
      } else {
        print("Invalid json type for station: ${json.runtimeType}");
      }
    } catch (parseE) {
      print("Parse error for station json $json: $parseE");
      // Skip este station, no crashea todo
    }
  }
  print("Parsed ${stations.length} stations successfully");
  
  return stations;
}