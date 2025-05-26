import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/new_password_view_model.dart';
import '../../common_widgets/custom_back_button.dart';

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewPasswordViewModel(),
      child: Consumer<NewPasswordViewModel>(
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
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '비밀번호 변경',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '새로운 비밀번호를 입력해주세요.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 새 비밀번호 입력
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: viewModel.newPasswordController,
                      obscureText: viewModel.obscureNewPassword,
                      onChanged: (_) => viewModel.notifyListeners(),
                      decoration: InputDecoration(
                        labelText: '새로운 비밀번호 (10~20자리 이내)',
                        labelStyle: const TextStyle(fontSize: 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            viewModel.obscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: viewModel.toggleNewPasswordVisibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 비밀번호 확인 입력
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: viewModel.confirmPasswordController,
                      obscureText: viewModel.obscureConfirmPassword,
                      onChanged: (_) => viewModel.notifyListeners(),
                      decoration: InputDecoration(
                        labelText: '비밀번호 확인',
                        labelStyle: const TextStyle(fontSize: 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            viewModel.obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: viewModel.toggleConfirmPasswordVisibility,
                        ),
                      ),
                    ),
                  ),
                  if (!viewModel.isSame &&
                      viewModel.confirmPasswordController.text.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(left: 20, top: 12),
                      child: Text(
                        '비밀번호가 일치하지 않습니다.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const Spacer(),

                  // 변경 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: viewModel.isFilled
                            ? () async {
                          final success = await viewModel.updatePassword();
                          if (success) {
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('비밀번호 변경에 실패했습니다.'),
                              ),
                            );
                          }
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: viewModel.isFilled
                              ? const Color(0xFF81C6FF)
                              : Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '변경하기',
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
