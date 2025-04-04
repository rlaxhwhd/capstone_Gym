import 'package:flutter/material.dart';
import '../../../view_models/find_password_viewmodel.dart';

class FindPasswordScreen extends StatefulWidget {
  const FindPasswordScreen({super.key});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FindPasswordViewModel _viewModel = FindPasswordViewModel();

  void _handleResetPassword() async {
    final message = await _viewModel.resetPassword(_emailController.text);

    if (message == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호 재설정 이메일이 전송되었습니다!')),
      );
      Navigator.pushNamed(context, '/login'); // 로그인 화면으로 이동
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 찾기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이메일을 입력해주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleResetPassword,
              child: const Text('비밀번호 재설정'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
