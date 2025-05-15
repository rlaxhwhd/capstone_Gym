import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/delete_account_viewmodel.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeleteAccountViewModel(),
      child: const DeleteAccountView(),
    );
  }
}

class DeleteAccountView extends StatelessWidget {
  const DeleteAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DeleteAccountViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('회원탈퇴')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('회원탈퇴 유의사항', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              '''
- 회원탈퇴 시 서비스에서 탈퇴되며, 회사가 운영하는 다른 계열 서비스에서도 이용이 불가합니다.
- 탈퇴한 계정은 복구되지 않으며, 기존 이용 기록은 삭제됩니다.
- 같은 이메일 주소로 재가입이 불가능할 수 있습니다.
''',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: viewModel.agreed,
                  onChanged: (value) => viewModel.toggleAgreement(value ?? false),
                ),
                const Expanded(
                  child: Text(
                    '유의사항을 모두 확인하였으며, 탈퇴에 동의합니다.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: viewModel.agreed && !viewModel.isDeleting
                    ? () => viewModel.deleteAccount(context)
                    : null,
                child: viewModel.isDeleting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('탈퇴하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
