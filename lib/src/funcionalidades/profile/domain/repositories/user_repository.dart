import 'package:dartz/dartz.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getUserProfile(String userId);
  Future<Either<Failure, bool>> updateUserProfile(UserEntity userEntity, String userId);
  //Future<Either<Failure, bool>> createUserProfile(UserEntity userEntity, String pwd);
  // Agrega más métodos si necesitas, e.g., para fallback o sync
}