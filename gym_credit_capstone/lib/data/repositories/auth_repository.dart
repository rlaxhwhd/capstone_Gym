import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class AuthException implements Exception {
  final String message;

  AuthException(this.message);
}

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // 현재 유저아이디
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // 회원가입
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('비밀번호가 너무 약합니다.');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('이미 사용 중인 이메일입니다.');
      } else {
        throw AuthException('회원가입 중 오류가 발생했습니다.');
      }
    } catch (e) {
      throw AuthException('알 수 없는 오류: ${e.toString()}');
    }
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
    final querySnapshot =
    await userCollection.where('email', isEqualTo: email.trim()).get();
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

  Future<String?> getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      print('FCM 토큰 가져오기 실패: $e');
      return null;
    }
  }


}
