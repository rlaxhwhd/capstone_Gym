import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/view_models/find_password_view_model.dart';
import 'package:gym_credit_capstone/views/common_widgets/input_section.dart';
import 'package:gym_credit_capstone/style/custom_colors.dart';
import 'package:gym_credit_capstone/views/common_widgets/CustomInputLine.dart';

class EmailInput extends StatelessWidget {
  final FindPasswordViewModel viewModel;
  final double spaceBetween = 5;

  const EmailInput({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    if (viewModel.currentPageIndex == 0) {
      {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              const Text(
                '비밀번호를 찾기 위해\n이메일을 입력해주세요',
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'NanumSquare',
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 38),

              InputSectionWidget(
                title: '',
                errorMessage: viewModel.fieldErrors['email'],
                child: Row(
                  children: [
                    Expanded(
                      child: CustomInputLine(
                        hintTextValue: '이메일 아이디',
                        controller: viewModel.emailController,
                        inputValue: '이메일',
                        suffixIcon:
                        viewModel.isEmailVerified
                            ? Icon(
                          Icons.check,
                          color: CustomColors.primaryColor,
                          size: 27,
                        )
                            : null,
                        onChanged: (value) {
                          viewModel.validateFieldAndUpdate('email', value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: TextButton(
                        onPressed:
                        viewModel.isCheckingEmail
                            ? null
                            : () async {
                          await viewModel.checkEmailDuplicateAndUpdate();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                          viewModel.isEmailVerified
                              ? CustomColors.primaryColor
                              : Colors.transparent,
                          side: BorderSide(
                            color:
                            viewModel.isEmailVerified
                                ? CustomColors.primaryColor
                                : Colors.grey.shade400,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor:
                          viewModel.isEmailVerified
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
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
                                  : '등록 확인',
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
            ],
          ),
        );
      }
    }
    else
      return Container();
  }
}