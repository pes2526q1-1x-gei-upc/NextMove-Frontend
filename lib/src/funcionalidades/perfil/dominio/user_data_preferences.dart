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
  final int numeroTelefono;
  final String idiomaPreferido;
  final String descripcion;
  final String modoPreferido;
  final String fotoPerfilUrl;

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