import 'package:nextmove_app/src/funcionalidades/perfil/dominio/user_data_preferences.dart';

Future<UserData> pushUserDataPreferences(UserData preferences) async {
  // Lógica para enviar a capa de datos
  print("Enviando preferencias de usuario desde capa de datos:");
  print("Apodo: ${preferences.apodo}");
  print("Nombre Completo: ${preferences.nombreCompleto}");
  print("Email: ${preferences.email}");
  print("Fecha de Nacimiento: ${preferences.fechaNacimiento}");
  //print("Password: ${preferences.password}");
  print("Fecha de Registro: ${preferences.fechaRegistro}");
  print("Número de Teléfono: ${preferences.numeroTelefono}");
  print("Idioma Preferido: ${preferences.idiomaPreferido}");
  print("Descripción: ${preferences.descripcion}");
  print("Modo Preferido: ${preferences.modoPreferido}");
  print("Foto Perfil URL: ${preferences.fotoPerfilUrl}"); 
  return Future.value(preferences);

}

UserData DBfetchUserDataPreferences(){
  // Lógica para obtener los datos del usuario desde la capa de datos
  // Aquí se devuelve un ejemplo estático
  return (UserData(
    apodo: "Abeet",
    nombreCompleto: "Albert González Braojos",
    email: "albert",
    fechaNacimiento: DateTime(1990, 1, 1),
    //password: "password123",
    fechaRegistro: DateTime(2022, 1, 1),
    numeroTelefono: 123456789,
    idiomaPreferido: "Español",
    descripcion: "Esta es una descripción de ejemplo.",
    modoPreferido: "Coche",
    fotoPerfilUrl: "assets/Profile",));
}
