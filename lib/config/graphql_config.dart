import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GraphQLConfig {
  // static String get baseUrl => dotenv.env['API_BASE_URL']!;
  static String get baseUrl {
    final url =
        dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.136:3000/graphql';
    print('GraphQL URL: $url'); // Log para debug
    return url;
  }

  static ValueNotifier<GraphQLClient> initializeClient() {
    final HttpLink httpLink = HttpLink(
      dotenv.env['GRAPHQL_ENDPOINT'] ?? 'http://192.168.1.136:3000/graphql',
    );

    final AuthLink authLink = AuthLink(
      getToken: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          return 'Bearer $token';
        }
        return null;
      },
    );

    final Link link = authLink.concat(httpLink);

    return ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(store: InMemoryStore()),
        link: link,
      ),
    );
  }
}
