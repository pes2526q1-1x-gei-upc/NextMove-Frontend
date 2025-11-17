import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/auth_service.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AuthRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

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

  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw AuthException(message: 'no-user');

      final firebaseUserId = user.uid;
      final firebaseToken = await user.getIdToken();

      final authService = AuthService(client);

      // For sign in, user should already exist, so just fetch meData
      final meData = await authService.getCurrentUser();

      return {
        'needsToRegister': meData?['needsToRegister'] ?? false,
        'meData': meData,
        'firebaseUserId': firebaseUserId,
        'firebaseToken': firebaseToken,
      };
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
        final authService = AuthService(client);
        await authService.upsertUserFromFirebase(
          firebaseUid: user.uid,
          email: user.email,
          name: user.displayName,
          needsToRegister: true,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.code);
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser == null) {
        return Future.error('Sign in aborted by user');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      // Once signed in, return the UserCredential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) throw AuthException(message: 'no-user');

      final firebaseUserId = userCredential.user!.uid;
      final firebaseToken = await userCredential.user?.getIdToken();
      print("🔑 Firebase ID Token (usa este en el header): $firebaseToken");
      print("📧 Email: ${userCredential.user?.email}");
      print("👤 Display Name: ${userCredential.user?.displayName}");

      final email = userCredential.user!.email;
      final name = userCredential.user!.displayName;

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      debugPrint("¿Es usuario nuevo? $isNewUser");

      final authService = AuthService(client);

      // Hacer upsert con needsToRegister solo si es nuevo
      /*
      await authService.upsertUserFromFirebase(
        firebaseUid: firebaseUserId,
        email: email,
        name: name,
        needsToRegister: isNewUser,
      );
      */
      final meData = await authService.getCurrentUser();

      final needsToRegister = meData?['needsToRegister'] ?? true;
      debugPrint("needsToRegister: $needsToRegister");

      return {
        'needsToRegister': needsToRegister,
        'meData': meData,
        'firebaseUserId': firebaseUserId,
        'firebaseToken': firebaseToken,
        'email': email,
      };
      
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.code);
    }
  }
}
