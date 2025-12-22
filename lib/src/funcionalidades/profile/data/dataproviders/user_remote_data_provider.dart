import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/mutations.dart';
import '../../domain/entities/user_entity.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart'
    as custom_exceptions;
import '../../../../../graphql/queries.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class UserRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<UserEntity> getUserProfile(String identifier) async {
    final currentUser = firebaseAuth.currentUser;
    if (kDebugMode) {
      print(
        "UserRemoteDataProvider: getUserProfile for $identifier. CurrentUser UID: ${currentUser?.uid}",
      );
    }

    // Cargar el perfil del usuario logeado
    if (currentUser != null && identifier == currentUser.uid) {
      if (kDebugMode) {
        print("UserRemoteDataProvider: Fetching MY profile");
      }

      return _fetchMyProfile();
    }
    // Cargar el perfil de otro usuario por su nickname
    else {
      if (kDebugMode) {
        print(
          "UserRemoteDataProvider: Fetching profile by nickname: $identifier",
        );
      }
      return _fetchUserProfileByNickname(identifier);
    }
  }

  Future<UserEntity> getUserProfileByEmail(String email) async {
    return _fetchProfile(email);
  }

  Future<UserEntity> _fetchMyProfile() async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getMeQuery),
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      if (kDebugMode) {
        print('Error GraphQL Raw: ${result.exception.toString()}');
      }
      throw custom_exceptions.ServerException(
        'Error al obtener perfil: ${result.exception}',
      );
    }

    final data = result.data?['me'];
    if (data == null) {
      if (kDebugMode) {
        print('No se encontró el usuario actual');
      }
      throw custom_exceptions.ServerException('No se encontró el usuario');
    }

    final statsData = await _fetchStatistics(data['email']);

    if (statsData != null) {
      data['statistics'] = statsData;
    }

    return UserEntity.fromRawData(data);
  }

  Future<UserEntity> _fetchProfile(String email) async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getUserQuery),
      variables: {'email': email},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      if (kDebugMode) {
        print('Error GraphQL Raw: ${result.exception.toString()}');
      }
      throw custom_exceptions.ServerException(
        'Error al obtener perfil: ${result.exception}',
      );
    }

    final data = result.data?['User'];
    if (data == null) {
      if (kDebugMode) {
        print('No se encontró el usuario con email: $email');
      }
      throw custom_exceptions.ServerException('No se encontró el usuario');
    }

    final statsData = await _fetchStatistics(email);

    if (statsData != null) {
      data['statistics'] = statsData;
    }

    return UserEntity.fromRawData(data);
  }

  Future<dynamic> _fetchStatistics(String email) async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getUserStats),
      //TODO: incloure totes les mètriques
      variables: {'email': email, 'metric': 'km_recorridos'},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      if (kDebugMode) {
        print('Error GraphQL Raw (stats): ${result.exception.toString()}');
      }
      throw custom_exceptions.ServerException(
        'Error al obtener estadísticas: ${result.exception}',
      );
    }

    final statsData = result.data?['userStats'];
    if (statsData == null) {
      if (kDebugMode) {
        print(
          'No se encontraron estadísticas para el usuario con email: $email',
        );
      }
      return;
    }

    return statsData;
  }

  Future<UserEntity> _fetchUserProfileByNickname(String nickname) async {
    debugPrint("Buscando perfil completo de: $nickname");

    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getUsersByNickname),
      variables: {'nickname': nickname},
      fetchPolicy: FetchPolicy.noCache,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw custom_exceptions.ServerException(
        'Error al obtener perfil de amigo: ${result.exception}',
      );
    }

    final List<dynamic> data = result.data?['UsersByNickname'] ?? [];

    if (data.isEmpty) {
      if (kDebugMode) {
        print("UserRemoteDataProvider: No users found for nickname $nickname");
      }
      throw custom_exceptions.ServerException('Perfil de amigo no encontrado');
    }
    final currentUser = firebaseAuth.currentUser;
    if (kDebugMode) {
      print("El usuario actual es: ${currentUser?.email}");
    }
    if (kDebugMode) {
      print(
        "UserRemoteDataProvider: Search results for '$nickname': ${data.map((u) => u['nickname']).toList()}",
      );
    }

    // Buscar coincidencia exacta
    final exactMatch = data.firstWhere(
      (userJson) =>
          (userJson['nickname'] as String).toLowerCase() ==
          nickname.toLowerCase(),
      orElse: () {
        if (kDebugMode) {
          print(
            "UserRemoteDataProvider: Exact match for '$nickname' not found in results.",
          );
        }
        return null;
      },
    );

    if (exactMatch == null) {
      throw custom_exceptions.ServerException('Usuario no encontrado');
    }

    if (kDebugMode) {
      print(
        "UserRemoteDataProvider: Found user: ${exactMatch['nickname']} (Email: ${exactMatch['email']})",
      );
    }

    return UserEntity.fromRawData(exactMatch);
  }

  // Mutation para actualizar el perfil
  Future<UserEntity> updateUserProfile(UserEntity userEntity) async {
    final user = firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw custom_exceptions.AuthException(
        message: 'Usuario no autenticado o email no disponible',
      );
    }

    const String updateUserMutation = GraphQLMutations.updateUserMutation;

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
        'fullName': userEntity.nombreCompleto.trim().isEmpty
            ? null
            : userEntity.nombreCompleto.trim(),
        'nickname': userEntity.apodo.trim().isEmpty
            ? null
            : userEntity.apodo.trim(),
        'phoneNumber': formatPhone(userEntity.numeroTelefono),
        'bioDescription': userEntity.descripcion.trim().isEmpty
            ? null
            : userEntity.descripcion.trim(),
        'preferredMode': UserEntity.mapPreferredModeToAPI(
          userEntity.modoPreferido,
        ),
        'preferredLanguage': UserEntity.mapLanguageToAPI(
          userEntity.idiomaPreferido,
        ),
        'birthDate': formatBirthDate(userEntity.fechaNacimiento),
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      if (kDebugMode) {
        print(
          'Error GraphQL Raw (updateUserProfile): ${result.exception.toString()}',
        );
      }
      if (kDebugMode) {
        print(
          'Error GraphQL Raw (updateUserProfile): ${result.exception.toString()}',
        );
      }
      if (result.exception?.graphqlErrors.isNotEmpty ?? false) {
        if (kDebugMode) {
          print(
            'GraphQL error message: ${result.exception!.graphqlErrors.first.message}',
          );
        }
        if (kDebugMode) {
          print(
            'GraphQL error message: ${result.exception!.graphqlErrors.first.message}',
          );
        }
      }
      throw custom_exceptions.ServerException(
        'Error al actualizar: ${result.exception}',
      );
    }

    final data = result.data?['updateMe'];
    if (data == null) {
      if (kDebugMode) {
        print('updateMe returned null data for user ${user.email}');
      }
      if (kDebugMode) {
        print('updateMe returned null data for user ${user.email}');
      }
      throw custom_exceptions.ServerException('No se actualizó el usuario');
    }

    await client.resetStore();

    return UserEntity.fromRawData(data);
  }

  Future<UserEntity> createUserProfile(UserEntity userEntity) async {
    final String birthDateFormatted = DateFormat(
      'yyyy-MM-dd',
    ).format(userEntity.fechaNacimiento);

    String modeEnum = 'CAR';
    if (userEntity.modoPreferido.toLowerCase().contains('bici')) {
      modeEnum = 'BIKE';
    }

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

    String? phoneNumberToSend;
    if (userEntity.numeroTelefono != 0) {
      phoneNumberToSend = userEntity.numeroTelefono.toString();
    }

    final MutationOptions options = MutationOptions(
      document: gql(GraphQLMutations.createUserMutation),
      variables: {
        'input': {
          'email': userEntity.email,
          'name': userEntity.nombreCompleto,
          'nickname': userEntity.apodo,
          'photo': userEntity.photo,
          'phoneNumber': phoneNumberToSend, // Envía null si es 0
          'preferredMode': modeEnum,
          'preferredLanguage': langEnum,
          'birthDate': birthDateFormatted,
          'bioDescription': userEntity.descripcion,
          'regWithGoogle': userEntity.regWithGoogle ?? false,
        },
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      if (kDebugMode) {
        print('Error GraphQL Raw: ${result.exception.toString()}');
      }
      if (kDebugMode) {
        print('Error GraphQL Raw: ${result.exception.toString()}');
      }
      if (result.exception!.graphqlErrors.isNotEmpty) {
        final msg = result.exception!.graphqlErrors.first.message;
        if (kDebugMode) {
          print('Mensaje del servidor: "$msg"');
        }
        if (kDebugMode) {
          print('Mensaje del servidor: "$msg"');
        }
      }

      throw custom_exceptions.ServerException(
        'Error al crear perfil: ${result.exception}',
      );
    }

    if (result.data != null && result.data!['createUser'] != null) {
      return UserEntity.fromRawData(result.data!['createUser']);
    } else {
      throw custom_exceptions.ServerException(
        'La respuesta del servidor fue nula',
      );
    }
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  Future<String> uploadProfilePhoto(File file) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw custom_exceptions.AuthException(message: 'Usuario no autenticado');
    }

    final token = await user.getIdToken();
    final endpoint = dotenv.env['GRAPHQL_ENDPOINT'];

    if (endpoint == null) {
      throw custom_exceptions.ServerException('GRAPHQL_ENDPOINT no definido');
    }

    // Asumimos que el endpoint es .../graphql y lo cambiamos a .../api/upload-profile-photo
    // O si el endpoint es solo el host, construimos la url.
    // Dado el código del backend, la ruta es /api/upload-profile-photo
    // Si GRAPHQL_ENDPOINT es http://localhost:3000/graphql
    final baseUrl = endpoint.replaceAll('/graphql', '');
    final uploadUrl = '$baseUrl/api/upload-profile-photo';

    if (kDebugMode) {
      print('Uploading photo to: $uploadUrl');
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.headers['Authorization'] = 'Bearer $token';

      // Determine mime type
      final mimeType = lookupMimeType(file.path);
      MediaType? mediaType;
      if (mimeType != null) {
        final split = mimeType.split('/');
        if (split.length == 2) {
          mediaType = MediaType(split[0], split[1]);
        }
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: mediaType,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['imageUrl'];
      } else {
        if (kDebugMode) {
          print('Upload failed: ${response.statusCode} - ${response.body}');
        }
        throw custom_exceptions.ServerException(
          'Error al subir foto: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception uploading photo: $e');
      }
      throw custom_exceptions.ServerException(
        'Error de conexión al subir foto',
      );
    }
  }
}
