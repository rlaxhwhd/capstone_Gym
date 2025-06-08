// lib/views/screens/login/components/IdPasswordStep.dart
import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/view_models/sign_up_view_model.dart';
import 'package:gym_credit_capstone/style/custom_colors.dart';
import 'package:gym_credit_capstone/views/common_widgets/CustomInputLine.dart';
import 'package:gym_credit_capstone/views/common_widgets/input_section.dart';
import 'package:provider/provider.dart';

class IdPasswordStep extends StatefulWidget {
  final SignUpViewModel viewModel;
  static double spaceBetween = 24;

  const IdPasswordStep({required this.viewModel, super.key});

  @override
  State<IdPasswordStep> createState() => _IdPasswordStepState();
}

class _IdPasswordStepState extends State<IdPasswordStep> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '아이디 및 비밀번호 설정',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'NanumSquare',
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '안전한 계정 생성을 위해 정보를 입력해주세요',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'NanumSquare',
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Form(
                key: widget.viewModel.formKeys[SignUpStep.idPassword.index],
                child: Consumer<SignUpViewModel>(
                  builder: (context, viewModel, child) {
                    return ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 8,
                      ),
                      children: [
                        // 이메일
                        InputSectionWidget(
                          title: '이메일',
                          errorMessage: viewModel
                              .idPasswordFieldErrors['email'],
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomInputLine(
                                  hintTextValue: '이메일 아이디',
                                  controller: viewModel.emailController,
                                  inputValue: '이메일',
                                  suffixIcon: viewModel.isEmailVerified
                                      ? Icon(
                                    Icons.check,
                                    color: CustomColors.primaryColor,
                                    size: 27,
                                  )
                                      : null,
                                  onChanged: (value) {
                                    viewModel.validateIdPasswordFieldAndUpdate(
                                        'email', value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: TextButton(
                                  onPressed: viewModel.isCheckingEmail
                                      ? null
                                      : () async {
                                    await viewModel
                                        .checkEmailDuplicateAndUpdate();
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: viewModel.isEmailVerified
                                        ? CustomColors.primaryColor
                                        : Colors.transparent,
                                    side: BorderSide(
                                      color: viewModel.isEmailVerified
                                          ? CustomColors.primaryColor
                                          : Colors.grey.shade400,
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    foregroundColor: viewModel.isEmailVerified
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (viewModel.isCheckingEmail) ...[
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<
                                                Color>(
                                              viewModel.isEmailVerified
                                                  ? Colors.white
                                                  : CustomColors.primaryColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                        viewModel.isCheckingEmail
                                            ? '확인 중...'
                                            : viewModel.isEmailVerified
                                            ? '확인 완료'
                                            : '중복확인',
                                        style: TextStyle(
                                          fontFamily: 'NanumSquare',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 비밀번호
                        InputSectionWidget(
                          title: '비밀번호',
                          subtitle: '8자 이상, 대소문자+숫자+특수문자(!@#\$%^&*)',
                          errorMessage: viewModel
                              .idPasswordFieldErrors['password'] ??
                              viewModel
                                  .idPasswordFieldErrors['passwordConfirm'],
                          child: Column(
                            children: [
                              CustomInputLine(
                                hintTextValue: '비밀번호',
                                controller: viewModel.passwordController,
                                inputValue: '비밀번호',
                                onChanged: (value) {
                                  viewModel.validateIdPasswordFieldAndUpdate(
                                      'password', value);
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomInputLine(
                                hintTextValue: '비밀번호 확인',
                                controller: viewModel.confirmPasswordController,
                                inputValue: '비밀번호 확인',
                                onChanged: (value) {
                                  viewModel.validateIdPasswordFieldAndUpdate(
                                      'passwordConfirm', value);
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: IdPasswordStep.spaceBetween * 2),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}