import 'package:firebase_auth/firebase_auth.dart';

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