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
      case 'Bicicleta':
        return 'BIKE';
      default:
        return 'CAR';
    }
  }
}

// Obtener datos del usuario desde Provider
UserData? fetchUserDataPreferencesFromProvider(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userData = userProvider.user;
  final firebaseUserId = userProvider.firebaseUserId;

  if (userData == null || firebaseUserId == null) {
    return null;
  }

  return UserData.fromGraphQL(userData, firebaseUserId);
}

// Enviar datos del usuario (delegado a capa de datos)
void sendUserDataPreferences(UserData preferences, BuildContext context) {
  pushUserDataPreferences(preferences, context);
}

// Obtener datos del usuario desde la base de datos (delegado a capa de datos)
UserData fetchUserDataPreferences() {
  return DBfetchUserDataPreferences();
}

// Actualizar datos del usuario
Future<void> updateUserDataPreferences(
  UserData preferences,
  BuildContext context,
) async {
  debugPrint("========================");
  debugPrint("Dominio: Actualizando preferencias del usuario");
  debugPrint("========================");

  // 1. Enviar a la API (capa de datos)
  await pushUserDataPreferences(preferences, context);

  // 2. Actualizar Provider para mantener sincronizado el estado local
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final currentUser = userProvider.user;

  if (currentUser != null) {
    final updatedUser = Map<String, dynamic>.from(currentUser);
    updatedUser['name'] = preferences.nombreCompleto;
    updatedUser['phoneNumber'] = preferences.numeroTelefono.toString();
    updatedUser['bioDescription'] = preferences.descripcion;
    updatedUser['preferredMode'] = UserData.mapPreferredModeToAPI(
      preferences.modoPreferido,
    );
    // birthDate se mantiene igual
    // photo se mantiene igual

    userProvider.setUser(
      updatedUser,
      firebaseUserId: userProvider.firebaseUserId,
      firebaseToken: userProvider.firebaseToken,
    );

    debugPrint("Provider actualizado correctamente");
  }
}