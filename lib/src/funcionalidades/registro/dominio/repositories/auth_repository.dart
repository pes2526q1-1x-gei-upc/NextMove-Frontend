

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';

abstract class AuthRepository {
  // Future<bool> isLoggedIn();
  Future<Either<Failure, bool>> isEmailRegistered(String email);
}