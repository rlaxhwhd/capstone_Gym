import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/routes.dart';
import '../../../view_models/login_viewmodel.dart';
import '../../../data/repositories/user_repository.dart';
import 'package:gym_credit_capstone/views/common_widgets/primary_button.dart';
import  'package:gym_credit_capstone/views/common_widgets/CustomInputLine.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginViewModel _viewModel;

  bool _obscurePassword = true;
  bool _isButtonEnabled = false; // 버튼 활성화 상태 추가

  _LoginScreenState() : _viewModel = LoginViewModel(UserRepository());

  @override
  void initState() {
    super.initState();
    // 텍스트 필드 변경 감지 리스너 추가
    _emailController.addListener(_validateInputs);
    _passwordController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 입력값 검증 함수
  void _validateInputs() {
    setState(() {
      _isButtonEnabled = _emailController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty;
    });
  }

  void _handleLogin() async {
    if (!_isButtonEnabled) return; // 버튼이 비활성화 상태면 함수 종료

    final result = await _viewModel.login(
      _emailController.text,
      _passwordController.text,
    );

    switch (result) {
      case LoginResult.success:
        Navigator.pushReplacementNamed(context, AppRoutes.main);
        break;
      case LoginResult.userNotFound:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('사용자를 찾을 수 없습니다.')));
        break;
      case LoginResult.incorrectPassword:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')));
        break;
      case LoginResult.error:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로그인 중 오류가 발생했습니다.')));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // 키보드에 의한 자동 리사이징 비활성화
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          padding: const EdgeInsets.only(
            left: 28,
            right: 28,
            top: 120,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontFamily: 'NanumSquare',
                  fontWeight: FontWeight.w900,
                  height: 1.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("안녕하세요"), Text("예약 서비스입니다.")],
                ),
              ),
              Text(
                "서비스 이용을 위해 로그인 해주세요.",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontFamily: 'NanumSquare',
                  fontWeight: FontWeight.bold,
                  height: 3,
                ),
              ),
              const SizedBox(height: 40),
              // 기존 TextFormField들을 CustomInputLine으로 대체한 코드

              CustomInputLine(
                hintTextValue: '아이디를 입력해주세요',
                controller: _emailController,
                inputValue: '',
              ),
              const SizedBox(height: 30),
              CustomInputLine(
                hintTextValue: '비밀번호를 입력해주세요',
                controller: _passwordController,
                inputValue: '',
                textStyle: const TextStyle(
                  fontFamily: null,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    "|",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/find_pw');
                    },
                    child: const Text(
                      '비밀번호 찾기',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                text: '로그인',
                onPressed: _isButtonEnabled ? _handleLogin : null, // 버튼 활성화 상태에 따라 함수 전달
              )
            ],
          ),
        ),
      ),
    );
  }
}