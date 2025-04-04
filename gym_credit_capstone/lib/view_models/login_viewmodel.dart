import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/user_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LoginViewModel(this._userRepository);

  Future<LoginResult> login(String email, String password) async {
    try {
      // 사용자 존재 확인
      bool userExists = await _userRepository.checkUserExists(email);
      if (!userExists) {
        return LoginResult.userNotFound;
      }

      // 비밀번호 인증
      try {
        await _auth.signInWithEmailAndPassword(
            email: email,
            password: password
        );
        return LoginResult.success;
      } catch (e) {
        return LoginResult.incorrectPassword;
      }
    } catch (e) {
      print('Login error: $e');
      return LoginResult.error;
    }
  }
}

enum LoginResult {
  success,
  userNotFound,
  incorrectPassword,
  error
}