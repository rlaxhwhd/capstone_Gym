import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // File 사용을 위해 추가

// -----------------------------------------------
import 'package:gym_credit_capstone/view_models/find_password_view_model.dart';
import 'package:gym_credit_capstone/views/common_widgets/step_indicator.dart';
import 'package:gym_credit_capstone/style/custom_colors.dart';

import 'package:gym_credit_capstone/views/screens/find_password/components/email_input.dart';
import 'package:gym_credit_capstone/views/screens/find_password/components/send_reset_email.dart';

import 'package:gym_credit_capstone/views/common_widgets/primary_button.dart';
import 'package:gym_credit_capstone/views/common_widgets/custom_back_button.dart';

class FindPassword extends StatelessWidget {
  const FindPassword({super.key});

  @override
  Widget build(BuildContext context) {
    // ViewModel을 Provider를 통해 생성하고 제공합니다.
    return ChangeNotifierProvider(
      create: (_) => FindPasswordViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Consumer<FindPasswordViewModel>(
          builder: (context, viewModel, child) {
            // 로딩 중일 때 화면 전체에 로딩 인디케이터 표시
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: CustomColors.primaryColor,
                ),
              );
            }

            return Column(
              children: [
                // 1. 단계 표시 인디케이터
                if (viewModel.currentPageIndex !=
                    FindPasswordViewModel.totalSteps - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 28, top: 8),
                    child:Column(
                      children: [
                        const SizedBox(height: 28),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CustomBackButton(
                            onPressed: () => viewModel.previousPage(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 에러 메시지 표시

                // 2. PageView: 각 단계별 화면
                Expanded(
                  child: PageView(
                    controller: viewModel.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      print("페이지 변경: $index");
                    },
                    // 스와이프로 페이지 전환 막기
                    children: [
                      EmailInput(viewModel: viewModel),
                      SendResetEmail(viewModel: viewModel),
                      // Step 3: 최종 회원가입
                    ],
                  ),
                ),

                // 3. 네비게이션 버튼 영역
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 28,
                  ),
                  child: PrimaryButton(
                    text: viewModel.primaryButtonText,
                    onPressed: viewModel.buttonAction(context), // 로딩 중 비활성화
                  ),
                ),
              ],
            );
          },
        ), //),
      ),
    );
  }
}
