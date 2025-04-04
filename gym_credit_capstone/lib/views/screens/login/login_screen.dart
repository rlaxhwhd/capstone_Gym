import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/routes.dart';
import '../../../view_models/login_viewmodel.dart';
import '../../../data/repositories/user_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState(); // 이 부분이 중요
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginViewModel _viewModel;

  _LoginScreenState() : _viewModel = LoginViewModel(UserRepository());

  void _handleLogin() async {
    final result = await _viewModel.login(
      _emailController.text,
      _passwordController.text,
    );

    switch (result) {
      case LoginResult.success:
        Navigator.pushNamed(context, AppRoutes.main);
        break;
      case LoginResult.userNotFound:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자를 찾을 수 없습니다.')),
        );
        break;
      case LoginResult.incorrectPassword:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
        );
        break;
      case LoginResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 중 오류가 발생했습니다.')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) { // build 메서드 추가
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('로그인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text('회원가입'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/find_pw');
              },
              child: const Text('비밀번호 찾기'),
            ),
          ],
        ),
      ),
    );
  }
}