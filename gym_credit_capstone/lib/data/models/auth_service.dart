import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 회원가입
  Future<UserCredential?> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 사용자 정보 저장
  Future<void> saveUserData(String uid, String email) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'createdAt': DateTime.now(),
    });
  }

  // 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // 사용자 존재 확인
  Future<bool> checkIsUserExists(String email) async {
    final userCollection = _firestore.collection('users');
    final querySnapshot = await userCollection.where('email', isEqualTo: email.trim()).get();
    return querySnapshot.docs.isNotEmpty;
  }

  // 비밀번호 확인
  Future<bool> checkIsPasswordCorrect(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }
  // 사용자 닉네임 가져오기
  Future<String?> getUserNickname(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc['nickname'];
    } catch (e) {
      throw Exception('닉네임 가져오기 실패: $e');
    }
  }
}
