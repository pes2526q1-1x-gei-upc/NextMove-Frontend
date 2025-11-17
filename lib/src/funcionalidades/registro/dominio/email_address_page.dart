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