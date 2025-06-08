import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

import '../models/user_model.dart';
import 'auth_repository.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authRepository;

  UserRepository({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  /// 유저 존재 여부 확인
  Future<bool> checkUserExists(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  Future<bool> checkNicknameExists(String nickname) async {
    try {
      final querySnapshot =
      await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname.trim())
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user nickname existence: $e');
      return false;
    }
  }

  Future<void> updateUserByEmail(String email, UserModel updatedUser) async {
    try {
      // 1. 이메일로 문서 찾기
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("해당 이메일로 등록된 유저 없음");
        return;
      }

      // 2. 첫 번째 일치하는 문서의 ID 얻기
      final docId = querySnapshot.docs.first.id;

      // 3. 해당 문서를 UserModel 기반으로 업데이트
      await _firestore
          .collection('users')
          .doc(docId)
          .update(updatedUser.toFirestore());

      print("유저 정보 업데이트 성공");
    } catch (e) {
      print("유저 업데이트 중 오류 발생: $e");
    }
  }

  /// 이메일로 유저 정보 가져오기
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
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


  /// 현재 유저의 uid와 email로 유저 정보 가져오기
  Future<UserModel?> getUserInfo(String uid, String? email) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && email != null) {
        return UserModel.fromFirestore({
          ...doc.data()!,
          'email': email,
        });
      }
      return null;
    } catch (e) {
      print('Error fetching user info: $e');
      return null;
    }
  }

  /// 유저가 좋아요한 체육관 리스트 가져오기
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

  /// 체육관 좋아요 토글
  Future<void> toggleLikedGym(String gymName, {String? userId}) async {
    userId ??= _authRepository.getCurrentUserId();

    if (userId == null) {
      print("Error: userId is null");
      return;
    }

    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        final List<String> likedGyms = List<String>.from(data['favorite'] ?? []);

        if (likedGyms.contains(gymName)) {
          await userRef.update({
            'favorite': FieldValue.arrayRemove([gymName])
          });
        } else {
          await userRef.update({
            'favorite': FieldValue.arrayUnion([gymName])
          });
        }
      }
    } catch (e) {
      print("Error toggling liked gym: $e");
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
