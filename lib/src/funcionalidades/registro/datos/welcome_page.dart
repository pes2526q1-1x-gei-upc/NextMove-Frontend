import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
      .authenticate();

  if (googleUser == null) {
    return Future.error('Sign in aborted by user');
  }

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = googleUser.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
  // Once signed in, return the UserCredential
  final userCredential = await FirebaseAuth.instance.signInWithCredential(
    credential,
  );

  // 🔑 AQUÍ obtienes el token de Firebase para el header
  final firebaseToken = await userCredential.user?.getIdToken();
  print("🔑 Firebase ID Token (usa este en el header): $firebaseToken");
  print("📧 Email: ${userCredential.user?.email}");
  print("👤 Display Name: ${userCredential.user?.displayName}");

  return userCredential;
}
