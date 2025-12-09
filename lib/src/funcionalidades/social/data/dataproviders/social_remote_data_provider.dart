import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/mutations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/graphql/queries.dart';

class SocialRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

  // Recupera el token actual para autenticar las peticiones
  Future<String?> get _authHeader async {
    final fireBaseUser = FirebaseAuth.instance.currentUser;
    String? authHeader = '';
    if (fireBaseUser != null) {
      final token = await fireBaseUser.getIdToken();
      authHeader = 'Bearer $token';
    }
    return authHeader;
  }

  Future<List<UserEntity>> getFriends() async {
    String? authHeader = await _authHeader;
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getFriends),
      context: Context().withEntry(HttpLinkHeaders(headers: {
        'Authorization': authHeader ?? '',
      })),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException('Fallo al cargar la lista de amigos: ${result.exception.toString()}');
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
        photo: json['photo'] ?? "",
      );
    }).toList();
  }

  Future<List<UserEntity>> searchUsers(String query) async {
    debugPrint("Buscando usuarios: '$query'");
    String? authHeader = await _authHeader;

    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getUsersByNickname),
      variables: {'nickname': query},
      context: Context().withEntry(HttpLinkHeaders(headers: {
        'Authorization': authHeader ?? '',
      })),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException('Error en la búsqueda: ${result.exception.toString()}');
    }

    final List<dynamic> usersData = result.data?['UsersByNickname'] ?? [];

    return usersData.map((json) {
      try {
        return UserEntity.fromRawData(json);
      } catch (e) {
        // Objeto por defecto si la respuesta no coincide con lo esperado
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
          photo: "",
        );
      }
    }).toList();
  }

  Future<void> addFriend(String friendNickname) async {
    String? authHeader = await _authHeader;
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLMutations.newFriendship),
      variables: {
        'nickname': friendNickname,
      },
      context: Context().withEntry(HttpLinkHeaders(headers: {
        'Authorization': authHeader ?? '',
      })),
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException('No se pudo enviar la solicitud: ${result.exception.toString()}');
    }
  }

  Future<void> removeFriend(String friendNickname) async {
    String? authHeader = await _authHeader;
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLMutations.deleteFriendship),
      variables: {
        'nickname': friendNickname,
      },
      context: Context().withEntry(HttpLinkHeaders(headers: {
        'Authorization': authHeader ?? '',
      })),
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException('Fallo al eliminar amigo: ${result.exception.toString()}');
    }
  }

  Future<void> blockUser(String userToBlockNickname) async {
    String? authHeader = await _authHeader;
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLMutations.blockUser),
      variables: {
        'nickname': userToBlockNickname,
      },
      context: Context().withEntry(HttpLinkHeaders(headers: {
        'Authorization': authHeader ?? '',
      })),
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException('Error al bloquear usuario: ${result.exception.toString()}');
    }
  }

  Future<List<UserEntity>> getBlockedUsers() async {
    String? authHeader = await _authHeader;
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getBlockList),
      context: Context().withEntry(HttpLinkHeaders(headers: {
        'Authorization': authHeader ?? '',
      })),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException('No se pudo obtener la lista de bloqueados: ${result.exception.toString()}');
    }

    final List<dynamic> data = result.data?['BlockList'] ?? [];

    return data.map((json) {
      final blockedNick = json['blocked'] ?? 'Desconocido';
      return UserEntity(
        email: "",
        apodo: blockedNick,
        nombreCompleto: blockedNick,
        fechaNacimiento: DateTime.now(),
        fechaRegistro: DateTime.now(),
        numeroTelefono: 0,
        idiomaPreferido: "Español",
        descripcion: "",
        modoPreferido: "BIKE",
        photo: json['photo'] ?? '',
      );
    }).toList();
  }

  Future<void> unblockUser(String userToUnblockNickname) async {
    String? authHeader = await _authHeader;
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLMutations.unBlockUser),
      variables: {
        'nickname': userToUnblockNickname,
      },
      context: Context().withEntry(HttpLinkHeaders(headers: {
        'Authorization': authHeader ?? '',
      })),
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException('Error al desbloquear usuario: ${result.exception.toString()}');
    }
  }
}
