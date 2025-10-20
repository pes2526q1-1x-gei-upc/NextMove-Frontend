import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/datos/user_data_preferences.dart';

enum ModoPreferido {
  coche,
  bicicleta
}

enum IdiomaPreferido {
  espanol,
  ingles,
  catala
}

class UserData{
  final String apodo;
  final String nombreCompleto;
  final String email;
  final DateTime fechaNacimiento;
  //final String password;
  final DateTime fechaRegistro;
  late final int numeroTelefono;
  late final String idiomaPreferido;
  late final String descripcion;
  late final String modoPreferido;
  late final String fotoPerfilUrl;

  UserData({
    required this.apodo,
    required this.nombreCompleto,
    required this.email,
    required this.fechaNacimiento,
    //required this.password,
    required this.fechaRegistro,
    required this.numeroTelefono,
    required this.idiomaPreferido,
    required this.descripcion,
    required this.modoPreferido,
    required this.fotoPerfilUrl,
  });
}

void sendUserDataPreferences(UserData preferences) {
  // Lógica para enviar a capa de datos
  pushUserDataPreferences(preferences);
}

UserData fetchUserDataPreferences() {
  // Lógica para obtener los datos del usuario desde la capa de datos
  return DBfetchUserDataPreferences();
}

void updateUserDataPreferences(UserData preferences) {
  // Lógica para actualizar los datos del usuario en la capa de datos
  UserData currentData = DBfetchUserDataPreferences();
  UserData finalData = currentData;

  // Comprobar que datos han cambiado y actualizar solo esos
  if(preferences.numeroTelefono != currentData.numeroTelefono) {
    // Actualizar número de teléfono
    finalData.numeroTelefono = preferences.numeroTelefono;
  }
  if(preferences.descripcion != currentData.descripcion) {
    // Actualizar descripción
    finalData.descripcion = preferences.descripcion;
  }
  if(preferences.fotoPerfilUrl != currentData.fotoPerfilUrl) {
    // Actualizar foto de perfil
    finalData.fotoPerfilUrl = preferences.fotoPerfilUrl;
  }
  if(preferences.modoPreferido != currentData.modoPreferido) {
    // Actualizar modo preferido
    finalData.modoPreferido = preferences.modoPreferido;
  }
  if(preferences.idiomaPreferido != currentData.idiomaPreferido) {
    // Actualizar idioma preferido
    finalData.idiomaPreferido = preferences.idiomaPreferido;
  }

  // Enviar datos actualizados a la capa de datos
  pushUserDataPreferences(finalData);
}