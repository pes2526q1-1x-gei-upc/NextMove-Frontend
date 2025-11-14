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
  const ConnectionException({String? message = 'Sin conexión disponible'}) : super(message: message);
}

// Excepción desconocida o genérica
class UnknownException extends AppException {
  const UnknownException({String? message = 'Excepción desconocida'}) : super(message: message);
}