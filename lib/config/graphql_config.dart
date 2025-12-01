import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GraphQLConfig {
  static ValueNotifier<GraphQLClient>? _client;

  static ValueNotifier<GraphQLClient> initializeClient() {
    final endpoint = dotenv.env['GRAPHQL_ENDPOINT'];

    if (endpoint == null) {
      throw Exception('GRAPHQL_ENDPOINT no está definida en .env');
    }

    final HttpLink httpLink = HttpLink(endpoint);

    final AuthLink authLink = AuthLink(
      getToken: () async {
        final fireBaseUser = FirebaseAuth.instance.currentUser;
        if (fireBaseUser != null) {
          final token = await fireBaseUser.getIdToken();
          return 'Bearer $token';
        }
        return null;
      },
    );

    final Link link = authLink.concat(httpLink);

    _client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(store: InMemoryStore()),
        link: link,
      ),
    );

    return _client!;
  }

  static ValueNotifier<GraphQLClient> get client {
    if (_client == null) {
      throw Exception('GraphQL client not initialized');
    }
    return _client!;
  }
}
