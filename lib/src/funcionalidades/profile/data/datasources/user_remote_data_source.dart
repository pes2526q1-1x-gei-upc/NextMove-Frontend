import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../domain/entities/user_entity.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart' as custom_exceptions;


class UserRemoteDataSource {
  final GraphQLClient graphQLClient;
  final FirebaseAuth firebaseAuth;

  UserRemoteDataSource({
    required this.graphQLClient,
    required this.firebaseAuth,
  });

  // Query para obtener el perfil (asumiendo una query 'getMe'; ajústala si difiere)
  Future<UserEntity> getUserProfile(String userId) async {
    final user = firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw custom_exceptions.AuthException(message: 'Usuario no autenticado o email no disponible');
    }

    const String getUserQuery = r'''
      query GetMe($email: String!) {
        getMe(email: $email) {
          email
          name
          nickname
          phoneNumber
          bioDescription
          preferredMode
          preferredLanguage
          birthDate
          createdAt
          needsToRegister
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(getUserQuery),
      variables: {'email': user.email},
    );

    final QueryResult result = await graphQLClient.query(options);

    if (result.hasException) {
      throw custom_exceptions.ServerException('Error al obtener perfil: ${result.exception}');
    }

    final data = result.data?['getMe'];
    if (data == null) {
      throw custom_exceptions.ServerException('No se encontró el usuario');
    }

    return UserEntity.fromRawData(data);
  }

  // Mutation para actualizar el perfil 
  Future<UserEntity> updateUserProfile(UserEntity userEntity) async {
    final user = firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw custom_exceptions.AuthException(message: 'Usuario no autenticado o email no disponible');
    }

    const String updateUserMutation = r'''
      mutation UpdateMe(
        $email: String!
        $name: String
        $nickname: String
        $phoneNumber: String
        $bioDescription: String
        $preferredMode: Mode
        $preferredLanguage: String
        $birthDate: String
        $needsToRegister: Boolean
      ) {
        updateMe(
          email: $email
          name: $name
          nickname: $nickname
          phoneNumber: $phoneNumber
          bioDescription: $bioDescription
          preferredMode: $preferredMode
          preferredLanguage: $preferredLanguage
          birthDate: $birthDate
          needsToRegister: $needsToRegister
        ) {
          email
          name
          nickname
          phoneNumber
          bioDescription
          preferredMode
          preferredLanguage
          birthDate
          needsToRegister
        }
      }
    ''';

    // Helpers de formato (de tu código)
    String? formatBirthDate(DateTime? date) {
      if (date == null) return null;
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    String? formatPhone(int? phone) {
      if (phone == null || phone == 0) return null;
      return phone.toString();
    }

    final MutationOptions options = MutationOptions(
      document: gql(updateUserMutation),
      variables: {
        'email': user.email,
        'name': userEntity.nombreCompleto.trim().isEmpty ? null : userEntity.nombreCompleto.trim(),
        'nickname': userEntity.apodo.trim().isEmpty ? null : userEntity.apodo.trim(),
        'phoneNumber': formatPhone(userEntity.numeroTelefono),
        'bioDescription': userEntity.descripcion.trim().isEmpty ? null : userEntity.descripcion.trim(),
        'preferredMode': UserEntity.mapPreferredModeToAPI(userEntity.modoPreferido),
        'preferredLanguage': UserEntity.mapLanguageToAPI(userEntity.idiomaPreferido),
        'birthDate': formatBirthDate(userEntity.fechaNacimiento),
        'needsToRegister': false,
      },
    );

    final QueryResult result = await graphQLClient.mutate(options);

    if (result.hasException) {
      throw custom_exceptions.ServerException('Error al actualizar: ${result.exception}');
    }

    final data = result.data?['updateMe'];
    if (data == null) {
      throw custom_exceptions.ServerException('No se actualizó el usuario');
    }

    return UserEntity.fromRawData(data);
  }

/*
  Future<UserEntity> createUserProfile(UserEntity userEntity, String pwd) async {
    
    const String createUserMutation = r'''
      mutation UpsertUser(
        $email: String!
        $name: String
        nickname: String
      ) {
        upsertUser(
          id: $id
          email: $email
          name: $name
        ) {
          id
          email
          name
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(createUserMutation),
      variables: {
        'id': user.uid,
        'email': user.email,
        'name': userEntity.nombreCompleto.trim().isEmpty ? null : userEntity.nombreCompleto.trim(),
        'needsToRegister': false,
      },
    );

    final QueryResult result = await graphQLClient.mutate(options);

    if (result.hasException) {
      throw custom_exceptions.ServerException('Error al crear perfil: ${result.exception}');
    }
  }*/
}