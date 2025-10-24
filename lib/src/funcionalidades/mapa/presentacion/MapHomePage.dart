import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/StationList.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';


import '../../../../graphql/queries.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});
  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Placeholder(),
          ),

          // Widget para mostrar datos del usuario
          Positioned(
            top: 160,
            left: 32,
            child: Query(
              options: QueryOptions(
                document: gql(GraphQLQueries.getMeQuery),
                fetchPolicy: FetchPolicy.networkOnly,
              ),
              // ESTO ES TEMPORAL PUEDES QUITARLO
              builder: (QueryResult result, {fetchMore, refetch}) {
                print('=== Flutter Query Debug ===');
                print('isLoading: ${result.isLoading}');
                print('hasException: ${result.hasException}');

                if (result.hasException) {
                  print('Exception type: ${result.exception.runtimeType}');
                  print('Link exception: ${result.exception?.linkException}');
                  print('GraphQL errors: ${result.exception?.graphqlErrors}');


                  if (result.exception?.linkException != null) {
                    final linkEx = result.exception!.linkException;
                    print('Link exception type: ${linkEx.runtimeType}');
                    print('Link exception toString: ${linkEx.toString()}');
                  }
                }

                if (result.data?['me'] == null) {
                  return const Text('No hay datos');
                }

                final user = result.data!['me'];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Usuario: ${user['nombre']}'),
                      Text('Email: ${user['email']}'),
                      Text('ID: ${user['id']}'),
                    ],
                  ),
                );
              },
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 80,
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Placeholder(),
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Placeholder(),
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Placeholder(),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 32,
            right: 32,
            top: 48,
            child: SizedBox(
              height: 48,
              child: Placeholder(),
            ),
          ),
          Positioned(
            top: 104,
            right: 32,
            child: IconButton(
              icon: Icon(Icons.list),
              iconSize: 48,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => StationList()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}