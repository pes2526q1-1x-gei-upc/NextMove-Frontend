import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart' as custom_exceptions;
import '../datasources/user_remote_data_source.dart';
import '../datasources/user_local_data_source.dart';

class UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<Either<Failure, UserEntity>> getUserProfile(String userId) async {
    try {
      final user = await remoteDataSource.getUserProfile(userId);
      return Right(user);
    } on custom_exceptions.ServerException {
      return Left(ServerFailure());
    } on custom_exceptions.AuthException {
      return Left(AuthFailure());
    } catch (e) {
      // Fallback a local si remote falla
      return Right(localDataSource.getFallbackUserProfile());
    }
  }

  Future<Either<Failure, bool>> updateUserProfile(UserEntity userEntity, String userId) async {
    try {
      await remoteDataSource.updateUserProfile(userEntity);
      return const Right(true);
    } on custom_exceptions.ServerException {
      return Left(ServerFailure());
    } on custom_exceptions.AuthException {
      return Left(AuthFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> createUserProfile(UserEntity userEntity, String pwd) async {
    try {
      //await remoteDataSource.createUserProfile(userEntity, pwd);
      return const Right(true);
    } on custom_exceptions.ServerException {
      return Left(ServerFailure());
    } on custom_exceptions.AuthException {
      return Left(AuthFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
    
  }
}