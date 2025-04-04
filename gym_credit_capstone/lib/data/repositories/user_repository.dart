import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_repository.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authRepository; // 이제 선택적으로 받을 수 있음

  // 생성자에서 AuthRepository를 직접 주입하도록 변경
  UserRepository({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  Future<bool> checkUserExists(String email) async {
    try {
      final querySnapshot =
      await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final querySnapshot =
      await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }
  //유저의 좋아요한 체육관 리스트 리턴하는 함수, userId가 없으면 기본으로 현재 사용자의 아이디 사용
  Future<List<String>> getLikedGymIds({String? userId}) async {
    userId ??= _authRepository.getCurrentUserId();

    if (userId == null) {
      print("Error: userId is null");
      return [];
    }

    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        return List<String>.from(data['favorite'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching liked gyms: $e");
      return [];
    }
  }
}
