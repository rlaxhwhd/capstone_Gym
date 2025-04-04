import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();


  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<UserCredential?> signUp(String email, String password) async {
    return await _authService.signUp(email, password);
  }

  Future<void> saveUserData(String uid, String email) async {
    await _authService.saveUserData(uid, email);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<bool> checkIsUserExists(String email) async {
    return await _authService.checkIsUserExists(email);
  }

  Future<bool> checkIsPasswordCorrect(String email, String password) async {
    return await _authService.checkIsPasswordCorrect(email, password);
  }
  // 닉네임 가져오기
  Future<String?> fetchUserNickname(String uid) async {
    return await _authService.getUserNickname(uid);
  }

}
