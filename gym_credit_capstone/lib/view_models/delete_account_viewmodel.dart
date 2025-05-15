import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteAccountViewModel extends ChangeNotifier {
  bool isDeleting = false;
  bool agreed = false;

  void toggleAgreement(bool value) {
    agreed = value;
    notifyListeners();
  }

  Future<void> deleteAccount(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    isDeleting = true;
    notifyListeners();

    try {
      final String email = user.email ?? '';

      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['email'] == email) {
          await FirebaseFirestore.instance.collection('users').doc(doc.id).delete();
          break;
        }
      }

      await user.delete();

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('회원탈퇴가 완료되었습니다.')),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('계정 삭제 중 문제가 발생했습니다. 다시 시도해주세요.')),
      );
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }
}
