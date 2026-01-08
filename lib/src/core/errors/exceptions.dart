abstract class AppException implements Exception {
  final String? message;

  const AppException({this.message});
}

class ServerException extends AppException {
  const ServerException([String? message]) : super(message: message);
}

class AuthException extends AppException {
  const AuthException({super.message});
}

class ConnectionException extends AppException {
  const ConnectionException({super.message = 'Sin conexión disponible'});
}

class UnknownException extends AppException {
  const UnknownException({super.message = 'Excepción desconocida'});
}