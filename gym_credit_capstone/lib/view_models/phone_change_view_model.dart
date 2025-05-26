import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneChangeViewModel extends ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  bool isInvalidFormat = false;

  bool get isValid {
    final phone = phoneController.text.trim();
    return _isPhoneFormatValid(phone);
  }

  /// 전화번호 형식 체크: 간단한 정규표현식
  bool _isPhoneFormatValid(String phone) {
    final regex = RegExp(r'^01[0|1|6-9]-\d{3,4}-\d{4}$');
    return regex.hasMatch(phone);
  }

  void onPhoneChanged(String value) {
    isInvalidFormat = !_isPhoneFormatValid(value.trim());
    notifyListeners();
  }

  Future<void> submitPhone(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final phone = phoneController.text.trim();
    if (!_isPhoneFormatValid(phone)) {
      isInvalidFormat = true;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final userEmail = user.email ?? '';
      final snapshot = await FirebaseFirestore.instance.collection('users').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['email'] == userEmail) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .update({'phone': phone});
          break;
        }
      }

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('휴대폰 번호가 변경되었습니다.')),
      );

      Navigator.of(context).pop(true); // ✅ ProfilePage에서 갱신 트리거
    } catch (e) {
      debugPrint('휴대폰 번호 변경 오류: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('변경 중 문제가 발생했습니다. 다시 시도해주세요.')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
