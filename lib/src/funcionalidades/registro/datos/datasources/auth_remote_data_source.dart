import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  // Future<bool> isLoggedIn();
  Future<bool> isEmailRegistered(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<bool> isEmailRegistered(String email) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: "1111111",
      );
      await credential.user?.delete();
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return true;
      }
      else {
        throw ServerException(e.code);
      }
    }
  }
}