import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // File 사용을 위해 추가

// -----------------------------------------------
import 'package:gym_credit_capstone/view_models/sign_up_view_model.dart';
import 'package:gym_credit_capstone/views/common_widgets/step_indicator.dart';
import 'package:gym_credit_capstone/views/screens/sign_up/components/form_page/agreement_step.dart';
import 'package:gym_credit_capstone/views/screens/sign_up/components/form_page/user_info_step.dart';
import 'package:gym_credit_capstone/views/screens/sign_up/components/form_page/id_password_step.dart';
import 'package:gym_credit_capstone/views/screens/sign_up/components/form_page/identity_verification_step.dart';
import 'package:gym_credit_capstone/views/screens/sign_up/components/form_page/final_result_step.dart';

import 'package:gym_credit_capstone/style/custom_colors.dart';
import 'package:gym_credit_capstone/views/common_widgets/primary_button.dart';
import 'package:gym_credit_capstone/views/common_widgets/custom_back_button.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ViewModel을 Provider를 통해 생성하고 제공합니다.
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body:
          Consumer<SignUpViewModel>(
          builder: (context, viewModel, child) {
            // 로딩 중일 때 화면 전체에 로딩 인디케이터 표시
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator(
                color: CustomColors.primaryColor,
              ));
            }

            return Column(
              children: [
                // 1. 단계 표시 인디케이터
                if (viewModel.currentPageIndex !=
                    SignUpViewModel.totalSteps - 1)
                  Column(
                    children: [
                      const SizedBox(height: 28),
                      Stack(
                        alignment: Alignment.center, // 기본 정렬은 center
                        children: [
                          Positioned(
                            left: 28,
                            child: CustomBackButton(
                              onPressed: () => viewModel.previousPage(context),
                            ),
                          ),
                          StepIndicator(
                            currentPage: viewModel.currentPageIndex,
                            totalSteps: SignUpViewModel.totalSteps,
                          ),
                        ],
                      ),
                    ],
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
                      AgreementStep(viewModel: viewModel),
                      // Step 0: 동의
                      IdentityVerificationStep(viewModel: viewModel),
                      // Step 1: 전화번호 인증
                      UserInfoStep(viewModel: viewModel),
                      // Step 2: 회원정보 입력
                      IdPasswordStep(viewModel: viewModel),
                      // Step 3: ID 비번
                      FinalResultStep(viewModel: viewModel),
                      // Step 3: 최종 회원가입
                    ],
                  ),
                ),

                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 3. 네비게이션 버튼 영역
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 28,
                  ),
                  child: PrimaryButton(
                    text:viewModel.primaryButtonText,
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
