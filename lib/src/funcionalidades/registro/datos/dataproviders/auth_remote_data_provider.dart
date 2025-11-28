import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/auth_service.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:email_validator/email_validator.dart';

class AuthRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

  Future<void> deleteAccount(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw AuthException(message: 'no-user');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.code);
    }
  }

  Future<Tuple2<bool, bool?>> isEmailRegisteredAndWithGoogle(
    String email,
  ) async {
    if (!EmailValidator.validate(email)) {
      throw AuthException(message: 'invalid-email');
    }

    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.existsUserQuery),
      variables: {"email": email},
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    final data = result.data?['ExistsUser'];
    final exists = data['exists'] as bool;
    final isRegWithGoogle = data['isRegWithGoogle'] == null ? null : data['isRegWithGoogle'] as bool;
    return Tuple2(exists, isRegWithGoogle);
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
          regWithGoogle: false,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.code);
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      debugPrint("Starting Google sign-in...");
      final GoogleSignInAccount googleUser;
      // Trigger the authentication flow
      try {
        googleUser = await GoogleSignIn.instance.authenticate();
      } on GoogleSignInException catch (e) {
        if (e.code != GoogleSignInExceptionCode.canceled) {
          debugPrint("GoogleSignInException: ${e.code}");
          throw AuthException(message: e.toString());
        }
        return {'cancelled': true};
      }
      debugPrint("Google user obtained: ${googleUser.email}");

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

      if (userCredential.user == null) {
        debugPrint("UserCredential user is null");
        throw AuthException(message: 'no-user');
      }

      final firebaseUserId = userCredential.user!.uid;
      final firebaseToken = await userCredential.user?.getIdToken();

      if (kDebugMode) {
        print("Firebase ID Token (usa este en el header): $firebaseToken");
        print("Email: ${userCredential.user?.email}");
        print("Display Name: ${userCredential.user?.displayName}");
      }

      final email = userCredential.user!.email;

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? true;
      if (kDebugMode) {
        print("¿Es usuario nuevo? $isNewUser");
      }

      final authService = AuthService(client);
      final meData = await authService.getCurrentUser();
      debugPrint("meData after Google sign-in: $meData");
      final needsToRegister = meData == null;
      if (kDebugMode) {
        print("needsToRegister: $needsToRegister");
      }

      return {
        'needsToRegister': needsToRegister,
        'meData': meData,
        'firebaseUserId': firebaseUserId,
        'firebaseToken': firebaseToken,
        'email': email,
      };
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: ${e.code}");
      throw ServerException(e.code);
    }
  }
}
