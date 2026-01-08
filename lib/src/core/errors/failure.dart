abstract class Failure {
  final String? message;

  const Failure({this.message});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message});
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({super.message = 'Sin conexión a internet'});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Error desconocido'});
}

class ValidationFailure extends Failure {
  ValidationFailure({String? message}) : super(message: message ?? 'Validation failed');
}