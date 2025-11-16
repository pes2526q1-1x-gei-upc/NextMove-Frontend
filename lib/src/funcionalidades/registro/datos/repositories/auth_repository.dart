import 'package:dartz/dartz.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/datasources/auth_remote_data_provider.dart';

class AuthRepository {
  final AuthRemoteDataProvider authRemoteDataProvider;
  AuthRepository() : authRemoteDataProvider = AuthRemoteDataProvider();

  Future<Either<Failure, bool>> isEmailRegistered(String email) async {
    try {
      return Right(await authRemoteDataProvider.isEmailRegistered(email));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await authRemoteDataProvider.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  Future<Either<Failure, void>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await authRemoteDataProvider.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> signInWithGoogle() async {
    try {
      final result = await authRemoteDataProvider.signInWithGoogle();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(UnknownFailure());
    }
  }
}
