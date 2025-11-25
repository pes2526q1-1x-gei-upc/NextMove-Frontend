import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import '../../../../../../graphql/queries.dart';

class SocialRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

  Future<List<UserEntity>> getFriends(String nickname) async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getFriends),
      variables: {'nickname': nickname},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException('Error al cargar amigos: ${result.exception.toString()}');
    }

    final List<dynamic> data = result.data?['ListFriends'] ?? [];

    return data.map((json) {
      final friendNick = json['name'] ?? 'Desconocido';
      return UserEntity(
        email: "", 
        apodo: friendNick,
        nombreCompleto: friendNick, 
        fechaNacimiento: DateTime.now(),
        fechaRegistro: DateTime.now(),
        numeroTelefono: 0,
        idiomaPreferido: "Español",
        descripcion: "",
        modoPreferido: "BIKE",
      );
    }).toList();
  }

  Future<List<UserEntity>> searchUsers(String query) async {
    debugPrint("Buscando usuarios por nickname: '$query'");

    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getUsersByNickname),
      variables: {'nickname': query}, 
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      debugPrint("Error en búsqueda: ${result.exception}");
      throw ServerException('Error en la búsqueda: ${result.exception.toString()}');
    }

    // La query devuelve una LISTA bajo la clave 'UsersByNickname'
    final List<dynamic> usersData = result.data?['UsersByNickname'] ?? [];
    debugPrint("Resultados encontrados: ${usersData.length}");

    return usersData.map((json) {
      try {
        return UserEntity.fromRawData(json);
      } catch (e) {
        debugPrint("Error mapeando usuario: $e");
        // Fallback robusto por si algún campo esencial viene null
        return UserEntity(
          email: json['email'] ?? "",
          apodo: json['nickname'] ?? query,
          nombreCompleto: json['name'] ?? query,
          fechaNacimiento: DateTime.now(),
          fechaRegistro: DateTime.now(),
          numeroTelefono: 0,
          idiomaPreferido: "Español",
          descripcion: "",
          modoPreferido: "BIKE",
        );
      }
    }).toList();
  }

  Future<void> addFriend(String myNickname, String friendNickname) async {
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.newFriendship),
      variables: {
        'nickname1': myNickname,
        'nickname2': friendNickname,
      },
    );
    debugPrint("Vamos a crear la amistad entre $myNickname y $friendNickname");
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      debugPrint('Error al añadir amigo: ${result.exception.toString()}');
      throw ServerException('Error al añadir amigo: ${result.exception.toString()}');
    }
  }

  Future<void> removeFriend(String myNickname, String friendNickname) async {
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.deleteFriendship),
      variables: {
        'nickname1': myNickname,
        'nickname2': friendNickname,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException('Error al eliminar amigo: ${result.exception.toString()}');
    }
  }
}