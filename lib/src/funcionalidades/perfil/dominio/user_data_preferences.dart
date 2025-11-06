import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/datos/user_data_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';

enum ModoPreferido {
  coche,
  bicicleta
}

enum IdiomaPreferido {
  espanol,
  ingles,
  catala
}

class UserData {
  final String apodo;
  final String nombreCompleto;
  final DateTime fechaNacimiento;
  final DateTime fechaRegistro;
  int numeroTelefono;
  late String idiomaPreferido;
  late String descripcion;
  late String modoPreferido;

  UserData({
    required this.apodo,
    required this.nombreCompleto,
    required this.fechaNacimiento,
    required this.fechaRegistro,
    required this.numeroTelefono,
    required this.idiomaPreferido,
    required this.descripcion,
    required this.modoPreferido,
  });

/// Aquí aplico el Patrón Factory!
  ///
  /// Un factory constructor NO crea el objeto directamente como un constructor normal.
  /// En su lugar, puede ejecutar lógica (validaciones, transformaciones, manejo de errores)
  /// ANTES de decidir cómo crear el objeto o incluso si crearlo.
  /// - Entrada: {"preferredMode": "CAR", "phoneNumber": "123"}
  /// - Proceso: Convierte "CAR" → "Coche", String "123" → int 123
  /// - Salida: UserData(modoPreferido: "Coche", numeroTelefono: 123)
  ///
  /// Sin factory tendríamos que repetir estas conversiones en cada pantalla.
  /// Con factory las hacemos una sola vez aquí (llamando UserData.fromGraphQl donde necesitemos)
  ///
  /// Facilita el mantenimiento: si cambia la API, solo se modifica aquí -> principio abierto cerrado
  /// Y un poco más de documentación para más tortura muajajaja https://dart.dev/language/constructors#factory-constructors

factory UserData.fromGraphQL(
    Map<String, dynamic> data,
    String firebaseUserId,
  ) {
    return UserData(
      apodo: data['name'] ?? 'Usuario',
      nombreCompleto: data['name'] ?? 'Nombre no disponible',
      fechaNacimiento: data['birthDate'] != null
          ? DateTime.parse(data['birthDate'])
          : DateTime.now(),
      fechaRegistro: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      numeroTelefono: data['phoneNumber'] != null
          ? int.tryParse(data['phoneNumber'].toString()) ?? 0
          : 0,
      idiomaPreferido: '', // No existe en la API GraphQL
      descripcion: data['bioDescription'] ?? '',
      modoPreferido: mapPreferredModeFromAPI(data['preferredMode']),
    );
  }

  // Helper para convertir Mode de API a String local
  static String mapPreferredModeFromAPI(String? apiMode) {
    if (apiMode == null) return 'Coche';

    switch (apiMode) {
      case 'CAR':
        return 'Coche';
      case 'BIKE':
        return 'Bicicleta';
      default:
        return 'Coche';
    }
  }

  // Helper para convertir String local a Mode de API
  static String mapPreferredModeToAPI(String localMode) {
    switch (localMode) {
      case 'Coche':
        return 'CAR';
      case 'Bici':
        return 'BIKE';
      default:
        return 'CAR';
    }
  }
}


UserData? fetchUserDataPreferencesFromProvider(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userData = userProvider.user;
  final firebaseUserId = userProvider.firebaseUserId;

  if (userData == null || firebaseUserId == null) {
    return null;
  }

  return UserData.fromGraphQL(userData, firebaseUserId);
}

// Enviar las preferencias del usuario a la capa de datos
void sendUserDataPreferences(UserData preferences, BuildContext context) {
  pushUserDataPreferences(preferences, context);    // a capa de datos
}

// Obtener las preferencias del usuario desde la capa de datos
UserData fetchUserDataPreferences() {
  return DBfetchUserDataPreferences();
}

Future<void> updateUserDataPreferences(
  UserData preferences,
  BuildContext context,
) async {
  debugPrint("========================");
  debugPrint("Dominio: Actualizando preferencias del usuario");
  debugPrint("========================");

  // llamada a API
  await pushUserDataPreferences(preferences, context);

  // Recordad que en el UserProvider tenemos guardado al usuario actual!! Por lo tanto, también hay que sincronizarlo
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final currentUser = userProvider.user;

  if (currentUser != null) {
    final updatedUser = Map<String, dynamic>.from(currentUser);
    updatedUser['name'] = preferences.nombreCompleto;
    updatedUser['phoneNumber'] = preferences.numeroTelefono.toString();
    updatedUser['bioDescription'] = preferences.descripcion;
    updatedUser['preferredMode'] = UserData.mapPreferredModeToAPI(preferences.modoPreferido);


    userProvider.setUser(
      updatedUser,
      firebaseUserId: userProvider.firebaseUserId,
      firebaseToken: userProvider.firebaseToken,
    );

    debugPrint("Provider actualizado correctamente");
  }
}