import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import '../../../../../../graphql/queries.dart';

class SocialRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

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
        'Authorization': ?authHeader,
      })),
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
        photo: json['photo'] ?? "",
      );
    }).toList();
  }

  Future<List<UserEntity>> searchUsers(String query) async {
    debugPrint("Buscando usuarios por nickname: '$query'");
    String? authHeader = await _authHeader;

    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getUsersByNickname),
      variables: {'nickname': query}, 
      context: Context().withEntry(HttpLinkHeaders(headers: {
        'Authorization': ?authHeader,
      })),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      debugPrint("Error en búsqueda: ${result.exception}");
      throw ServerException('Error en la búsqueda: ${result.exception.toString()}');
    }

    final List<dynamic> usersData = result.data?['UsersByNickname'] ?? [];
    debugPrint("Resultados encontrados: ${usersData.length}");

    return usersData.map((json) {
      try {
        return UserEntity.fromRawData(json);
      } catch (e) {
        debugPrint("Error mapeando usuario: $e");
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
      document: gql(GraphQLQueries.newFriendship),
      variables: {
        'nickname': friendNickname,
      },
      context: Context().withEntry(HttpLinkHeaders(headers: {
        'Authorization': ?authHeader,
      })),
    );
    debugPrint("Vamos a crear la amistad con $friendNickname");
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      debugPrint('Error al añadir amigo: ${result.exception.toString()}');
      throw ServerException('Error al añadir amigo: ${result.exception.toString()}');
    }
  }

  Future<void> removeFriend(String friendNickname) async {
    String? authHeader = await _authHeader;
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.deleteFriendship),
      variables: {
        'nickname': friendNickname,
      },
      context: Context().withEntry(HttpLinkHeaders(headers: {
        'Authorization': ?authHeader,
      })),
    );
    debugPrint("header en removeFriend: $authHeader");

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      if (result.exception!.graphqlErrors.isNotEmpty) {
        debugPrint("Error GraphQL del Servidor: ${result.exception!.graphqlErrors.first.message}");
      }
      if (result.exception!.linkException != null) {
        debugPrint("Error de Red/Link: ${result.exception!.linkException}");
      }
      
      throw ServerException('Error al eliminar amigo: ${result.exception.toString()}');
    }
  }

  Future<void> blockUser(String userToBlockNickname) async {
    String? authHeader = await _authHeader;
    debugPrint("Solicitando bloqueo de: $userToBlockNickname");
    debugPrint("header en blockUser: $authHeader");

    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.blockUser),
      variables: {
        'nickname': userToBlockNickname,
      },
      context: Context().withEntry(HttpLinkHeaders(headers: {
        'Authorization': authHeader ?? '',
      })),
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      if (result.exception!.graphqlErrors.isNotEmpty) {
        debugPrint("Error GraphQL del Servidor: ${result.exception!.graphqlErrors.first.message}");
      }
      if (result.exception!.linkException != null) {
        debugPrint("Error de Red/Link: ${result.exception!.linkException}");
      }
      
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
      throw ServerException('Error al cargar usuarios bloqueados: ${result.exception.toString()}');
    }

    final List<dynamic> data = result.data?['BlockList'] ?? [];

    return data.map((json) {
      final blockedNick = json['blocked'] ?? 'Desconocido';
      final photo = json['photo'] ?? '';
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
        photo: photo,
      );
    }).toList();
  }

  Future<void> unblockUser(String userToUnblockNickname) async {
    String? authHeader = await _authHeader;
    debugPrint("Solicitando desbloqueo de: $userToUnblockNickname");

    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.unBlockUser),
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