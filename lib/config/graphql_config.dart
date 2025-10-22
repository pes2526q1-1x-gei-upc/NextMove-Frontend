import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GraphQLConfig {
  // static String get baseUrl => dotenv.env['API_BASE_URL']!;
  static String get baseUrl {
    final url =
        dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.136:3000/graphql';
    print('GraphQL URL: $url'); // Log para debug
    return url;
  }

  static HttpLink httpLink = HttpLink(baseUrl);

  static GraphQLClient getClient() {
    return GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    ); // defino cliente GraphQL para usarlo donde sea
  }

  static ValueNotifier<GraphQLClient> initializeClient() {
    return ValueNotifier(getClient());
  }
}
