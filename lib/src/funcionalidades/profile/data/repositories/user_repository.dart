import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart' as custom_exceptions;
import '../dataproviders/user_remote_data_provider.dart';
import '../dataproviders/user_local_data_provider.dart';

class UserRepository {
  final UserRemoteDataProvider remoteDataProvider;
  final UserLocalDataProvider localDataProvider;

  UserRepository() : remoteDataProvider = UserRemoteDataProvider(), localDataProvider = UserLocalDataProvider();

  Future<Either<Failure, UserEntity>> getUserProfile(String userId) async {
    try {
      final user = await remoteDataProvider.getUserProfile(userId);
      return Right(user);
    } on custom_exceptions.ServerException {
      return Left(ServerFailure());
    } on custom_exceptions.AuthException {
      return Left(AuthFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> updateUserProfile(UserEntity userEntity) async {
    try {
      await remoteDataProvider.updateUserProfile(userEntity);
      return const Right(true);
    } on custom_exceptions.ServerException {
      return Left(ServerFailure());
    } on custom_exceptions.AuthException {
      return Left(AuthFailure());
    } catch (e) {
      debugPrint('❌ Error desconocido al actualizar perfil: $e');
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, UserEntity>> createUserProfile(UserEntity userEntity) async {
    try {
      final createdUser = await remoteDataProvider.createUserProfile(userEntity);
      return Right(createdUser);
    } on custom_exceptions.ServerException {
      return Left(ServerFailure());
    } on custom_exceptions.AuthException {
      return Left(AuthFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
    
  }
}