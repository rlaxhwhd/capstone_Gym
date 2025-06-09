import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------
import 'package:gym_credit_capstone/view_models/identity_verification_view_model.dart';
import 'package:gym_credit_capstone/views/common_widgets/step_indicator.dart';
import 'package:gym_credit_capstone/views/screens/identity_verification/components/mobile_carrier_picker.dart';
import 'package:gym_credit_capstone/views/screens/identity_verification/components/user_tel.dart';
import 'package:gym_credit_capstone/views/screens/identity_verification/components/sms_verification.dart';
import 'package:gym_credit_capstone/views/screens/identity_verification/components/final_result.dart';
// -----------------------------------------------

import 'package:gym_credit_capstone/style/custom_colors.dart';
import 'package:gym_credit_capstone/views/common_widgets/primary_button.dart';
import 'package:gym_credit_capstone/views/common_widgets/custom_back_button.dart';

class IdentityVerification extends StatelessWidget {
  const IdentityVerification({super.key});

  @override
  Widget build(BuildContext context) {
    // ViewModel을 Provider를 통해 생성하고 제공합니다.
    return ChangeNotifierProvider(
      create: (_) => IdentityVerificationViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Consumer<IdentityVerificationViewModel>(
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
                  if (viewModel.currentPageIndex <
                      IdentityVerificationViewModel.totalSteps - 1)
                    Container(
                      height: 65, // 명시적인 높이 지정
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 28,
                            child: CustomBackButton(
                              onPressed: () => viewModel.previousPage(context),
                            ),
                          ),
                          StepIndicator(
                            currentPage: viewModel.currentPageIndex,
                            totalSteps:
                                IdentityVerificationViewModel.totalSteps,
                          ),
                        ],
                      ),
                    ),

                  // 2. PageView: 각 단계별 화면
                  Expanded(
                    child:
                    // 방법 1: onPageChanged에서 로그 추가해서 문제 확인
                    PageView(
                      controller: viewModel.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        print('🔥 [DEBUG] PageView onPageChanged 호출됨: $index');
                        print(
                          '🔥 [DEBUG] 현재 viewModel._currentPageIndex: ${viewModel.currentPageIndex}',
                        );
                        viewModel.updateCurrentPage(index);
                        print(
                          '🔥 [DEBUG] updateCurrentPage 후 viewModel._currentPageIndex: ${viewModel.currentPageIndex}',
                        );
                      },
                      // 스와이프로 페이지 전환 막기
                      children: [
                        MobileCarrierPicker(viewModel: viewModel),
                        // Step 1: 통신사 선택
                        UserTel(viewModel: viewModel),
                        // Step 2: 전화번호 입력
                        SmsVerification(viewModel: viewModel),
                        // Step 3: 인증 방법 안내
                        FinalResult(viewModel: viewModel),
                        //최종 결과화면
                      ],
                    ),
                  ),

                  // 에러 메시지 표시
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
                    padding: EdgeInsets.fromLTRB(28, 5, 28, 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (viewModel.currentPageIndex == 2)
                          PrimaryButton(
                            text: '인증 메시지 보내기',
                            onPressed: () {
                              viewModel.sendSms();
                            },
                          ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: viewModel.buttonText,
                          onPressed:
                              viewModel.isLoading
                                  ? null
                                  : viewModel.buttonAction(context),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
