import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/delete_account_viewmodel.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provider로부터 DeleteAccountViewModel을 가져옵니다.
    final deleteAccountViewModel = Provider.of<DeleteAccountViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('계정탈퇴'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Text('정말로 탈퇴하시겠습니까?'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 취소 버튼: 이전 화면으로 돌아갑니다.
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                await deleteAccountViewModel.deleteUserAccount(context); // 계정 삭제 로직 실행
              },
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}