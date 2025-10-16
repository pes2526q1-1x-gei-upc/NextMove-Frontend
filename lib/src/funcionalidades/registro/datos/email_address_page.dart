import 'package:firebase_auth/firebase_auth.dart';

Future<bool> isEmailRegistered(String emailAddress) async {
  try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: "1111111",
      );
      await credential.user?.delete();
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return true;
      }
      else {
        rethrow;
      }
    }
}

Future<void> dataCreateUserWithEmailAndPassword({required String email, required String password}) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException {
    rethrow;
  }
}

Future<void> dataSignInWithEmailAndPassword({required String email, required String password}) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException {
    rethrow;
  }
}