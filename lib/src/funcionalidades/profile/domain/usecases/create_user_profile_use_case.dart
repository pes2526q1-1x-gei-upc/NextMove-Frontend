/* import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/data/repositories/user_repository.dart';
import '../../../../core/errors/failure.dart';

class CreateUserProfileUseCase {
  final UserRepository repository;

  CreateUserProfileUseCase(this.repository);

  Future<Either<Failure, bool>> call(UserEntity userEntity, String userId) {
    return repository.createUserProfile(userEntity, userId);
  }
} */