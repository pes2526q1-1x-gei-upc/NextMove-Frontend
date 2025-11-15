import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';

class AuthRemoteDataProvider {
  Future<bool> isEmailRegistered(String email) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: "1111111");
      await credential.user?.delete();
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return true;
      } else if (e.code == 'invalid-email') {
        throw AuthException(message: e.code);
      } else {
        throw ServerException(e.code);
      }
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw AuthException(message: e.code);
      } else {
        throw ServerException(e.code);
      }
    }
  }
}
