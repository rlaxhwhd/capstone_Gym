import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NicknameChangeViewModel extends ChangeNotifier {
  final TextEditingController nicknameController = TextEditingController();
  bool isDuplicate = false;
  bool isLoading = false;

  bool get isValid => nicknameController.text.trim().isNotEmpty;

  /// 사용자가 입력할 때 중복 상태 초기화
  void onNicknameChanged(String value) {
    isDuplicate = false;
    notifyListeners();
  }

  /// Firestore에서 닉네임 중복 확인
  Future<bool> isNicknameDuplicate(String nickname) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('nickname', isEqualTo: nickname)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// 닉네임 제출
  Future<void> submitNickname(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final nickname = nicknameController.text.trim();
    if (nickname.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      // 중복 검사
      final isDup = await isNicknameDuplicate(nickname);
      if (isDup) {
        isDuplicate = true;
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('이미 사용 중인 닉네임입니다.')),
        );
        return;
      }

      // 사용자 이메일 기반 문서 찾기
      final userEmail = user.email ?? '';
      final snapshot = await FirebaseFirestore.instance.collection('users').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['email'] == userEmail) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .update({'nickname': nickname});
          break;
        }
      }

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('닉네임이 변경되었습니다.')),
      );

      Navigator.of(context).pop(true); // ✅ 변경됨을 알림
    } catch (e) {
      debugPrint('닉네임 변경 오류: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('닉네임 변경 중 오류가 발생했습니다.')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }
}
