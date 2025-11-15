import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/auth_service.dart';

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

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // ignore: use_build_context_synchronously
        final client = null; // TODO: Pass the GraphQL client here as needed
        // ignore: unnecessary_null_comparison
        if (client != null) {
          final authService = AuthService(client);
          await authService.upsertUserFromFirebase(
            firebaseUid: user.uid,
            email: user.email,
            name: user.displayName,
            needsToRegister: true,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.code);
    }
  }
}
