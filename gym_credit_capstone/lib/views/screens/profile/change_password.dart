import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/change_password_view_model.dart';
import '../../../routes.dart';
import '../../common_widgets/custom_back_button.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(),
      child: Consumer<ChangePasswordViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 0, 30),
                    child: CustomBackButton(),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: Text(
                      '비밀번호 변경',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: Text(
                      '현재 비밀번호를 입력해주세요.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: viewModel.currentPasswordController,
                      obscureText: viewModel.obscureText,
                      decoration: InputDecoration(
                        labelText: '현재 비밀번호',
                        labelStyle: const TextStyle(
                          fontSize: 21,
                          color: Colors.black,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            viewModel.obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: viewModel.togglePasswordVisibility,
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  if (viewModel.showError)
                    const Padding(
                      padding: EdgeInsets.only(left: 20, top: 12),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 20),
                          SizedBox(width: 6),
                          Text(
                            '비밀번호가 맞지 않습니다.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () {
                        // 비밀번호 찾기 기능 연결
                      },
                      child: const Text(
                        '비밀번호 찾기',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF69B7FF),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF69B7FF),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final success =
                          await viewModel.verifyPasswordWithFirebase();
                          if (success) {
                            final result = await Navigator.pushNamed(
                              context,
                                AppRoutes.newPassword
                            );
                            if (result == true) {
                              Navigator.pop(context, true); // ✅ ProfilePage로 true 전달
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF81C6FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '다음',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
