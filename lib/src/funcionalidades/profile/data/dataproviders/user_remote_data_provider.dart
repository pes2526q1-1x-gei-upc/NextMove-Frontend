import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import '../../domain/entities/user_entity.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart' as custom_exceptions;


class UserRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

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

    final QueryResult result = await client.query(options);

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

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw custom_exceptions.ServerException('Error al actualizar: ${result.exception}');
    }

    final data = result.data?['updateMe'];
    if (data == null) {
      throw custom_exceptions.ServerException('No se actualizó el usuario');
    }

    return UserEntity.fromRawData(data);
  }


  Future<UserEntity> createUserProfile(UserEntity userEntity) async {
    const String createUserMutation = r'''
      mutation CreateUser($input: CreateUserInput!) {
        createUser(createInfo: $input) {
          email
          name
          nickname
          phoneNumber
          preferredMode
          preferredLanguage
          birthDate
          bioDescription
        }
      }
    ''';

    // 1. Formateo de Fecha (DD-MM-AAAA según tu esquema)
    final String birthDateFormatted = DateFormat('dd-MM-yyyy').format(userEntity.fechaNacimiento);

    // 2. Mapeo de Modo (Enum)
    // Aseguramos que coincida con los valores del esquema: CAR, BIKE
    String modeEnum = 'CAR'; 
    if (userEntity.modoPreferido.toLowerCase().contains('bici')) {
      modeEnum = 'BIKE';
    }

    // 3. Mapeo de Idioma (Enum)
    // Aseguramos que coincida con: ESP, CAT, ENG
    String langEnum = 'ESP';
    switch (userEntity.idiomaPreferido.toLowerCase()) {
      case 'en':
      case 'english':
        langEnum = 'ENG';
        break;
      case 'ca':
      case 'català':
      case 'catalan':
        langEnum = 'CAT';
        break;
    }

    // 4. Limpieza del Teléfono
    // Si es 0 (valor por defecto), enviamos NULL, no "0", para evitar errores de validación en backend
    String? phoneNumberToSend;
    if (userEntity.numeroTelefono != 0) {
      phoneNumberToSend = userEntity.numeroTelefono.toString();
    }

    // 5. Ejecutar mutación
    final MutationOptions options = MutationOptions(
      document: gql(createUserMutation),
      variables: {
        'input': {
          'email': userEntity.email,
          'name': userEntity.nombreCompleto,
          'nickname': userEntity.apodo,
          'phoneNumber': phoneNumberToSend, // Ahora enviamos null si no hay teléfono
          'preferredMode': modeEnum,
          'preferredLanguage': langEnum,
          'birthDate': birthDateFormatted,
          'bioDescription': userEntity.descripcion,
        }
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      // Imprimimos el error completo para depurar
      print('Error GraphQL Raw: ${result.exception.toString()}');
      
      // Si el mensaje viene vacío, suele ser un error de servidor no controlado
      if (result.exception!.graphqlErrors.isNotEmpty) {
         final msg = result.exception!.graphqlErrors.first.message;
         if (msg.isEmpty) {
           throw custom_exceptions.ServerException('Error interno del servidor (Mensaje vacío). Revisa los logs del backend.');
         }
      }
      
      throw custom_exceptions.ServerException('Error al crear perfil: ${result.exception}');
    }

    if (result.data != null && result.data!['createUser'] != null) {
      return UserEntity.fromRawData(result.data!['createUser']);
    } else {
      throw custom_exceptions.ServerException('La respuesta del servidor fue nula');
    }
  }
}