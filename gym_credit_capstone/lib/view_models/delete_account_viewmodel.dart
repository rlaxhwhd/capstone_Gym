import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteAccountViewModel extends ChangeNotifier {
  Future<void> deleteUserAccount(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final String email = user.email.toString();
        QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();

        for (var doc in snapshot.docs) {
          var userData = doc.data() as Map<String, dynamic>;

          if (userData['email'] == email) {
            // Firestore 데이터 삭제
            await FirebaseFirestore.instance.collection('users').doc(doc.id).delete();
            // Firebase 계정 삭제
            await user.delete();

            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('계정 삭제가 완료되었습니다.')),
            );

            Navigator.pushNamed(context, '/login'); // 로그인 화면으로 이동
            return;
          }
        }
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('계정 삭제 중 문제가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }
}