import 'package:dartz/dartz.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/datasources/auth_remote_data_source.dart';
import 'package:nextmove_app/src/funcionalidades/registro/dominio/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  AuthRepositoryImpl(this.authRemoteDataSource);

  // @override
  // Future<bool> isLoggedIn() async {
  //   throw UnimplementedError();
  // }

  @override
  Future<Either<Failure, bool>> isEmailRegistered(String email) async {
    try {
      return Right(await authRemoteDataSource.isEmailRegistered(email));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(UnknownFailure());
    }
  }}