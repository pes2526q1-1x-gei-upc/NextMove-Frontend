import 'package:flutter/material.dart';

// Provider para proveer la instancia usuario "a nivel global de app"
// Esta instancia guarda:
// 1. El el json devuelto por la query me de la API interna
// 2. El id del usuario guardado en firebase
// 3. El token JWT que ha devuelto firebase para el usuario
class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _firebaseUserId;
  String? _firebaseToken;

  String? _email;
  String? _pwd;

  Map<String, dynamic>? get user => _user;
  String? get firebaseUserId => _firebaseUserId;
  String? get firebaseToken => _firebaseToken;
  String? get email => _email;
  String? get pwd => _pwd;

  void setUser(
    Map<String, dynamic> userData, {
    String? firebaseUserId,
    String? firebaseToken,
  }) {
    _user = userData;
    _firebaseUserId = firebaseUserId;
    _firebaseToken = firebaseToken;
    notifyListeners();
  }

  void setEmailPwd(
    String? email,
    String? pwd
  ){
    _email = email;
    _pwd = pwd;
  }

  void setEmail(
    String? email,
  ){
    _email = email;
  }

  void clearUser() {
    _user = null;
    _firebaseUserId = null;
    _firebaseToken = null;
    notifyListeners();
  }
}
