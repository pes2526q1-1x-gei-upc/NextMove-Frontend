abstract class AppException implements Exception {
  final String? message;

  const AppException({this.message});
}

// Excepción genérica de servidor/API/GraphQL
class ServerException extends AppException {
  const ServerException([String? message]) : super(message: message);
}

// Excepción de autenticación (e.g., token inválido, usuario no logueado)
class AuthException extends AppException {
  const AuthException({super.message});
}

// Excepción de conexión (e.g., timeout, no internet)
class ConnectionException extends AppException {
  const ConnectionException({super.message = 'Sin conexión disponible'});
}

// Excepción desconocida o genérica
class UnknownException extends AppException {
  const UnknownException({super.message = 'Excepción desconocida'});
}