import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/email_address_page.dart';

enum PasswordValidationError {
  valid,
  tooShort,
  needsLowercase,
  needsUppercase,
  needsNumber,
  needsSpecialCharacter,
}

PasswordValidationError isPasswordValid(String password) {
  if (password.length < 8) {
    return PasswordValidationError.tooShort;
  }
  if (!RegExp(r'[a-z]').hasMatch(password)) {
    return PasswordValidationError.needsLowercase;
  }
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return PasswordValidationError.needsUppercase;
  }
  if (!RegExp(r'[0-9]').hasMatch(password)) {
    return PasswordValidationError.needsNumber;
  }
  if (!RegExp(r'[!@#\$&*~%^(),.?":{}|<>]').hasMatch(password)) {
    return PasswordValidationError.needsSpecialCharacter;
  }
  return PasswordValidationError.valid;
}

Future<void> createUserWithEmailAndPassword({required String email, required String password}) async {
  try {
   await dataCreateUserWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException {
    rethrow;
  }
}

Future<void> signInWithEmailAndPassword({required String email, required String password}) async {
  try {
    await dataSignInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException {
    rethrow;
  }
}