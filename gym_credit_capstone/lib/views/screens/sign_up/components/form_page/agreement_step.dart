// lib/views/screens/login/components/step1_name.dart
import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/view_models/sign_up_view_model.dart';
import 'package:gym_credit_capstone/views/common_widgets/terms_dialog.dart';
import 'package:gym_credit_capstone/views/common_widgets/check_box_list.dart';

class AgreementStep extends StatelessWidget {
  final SignUpViewModel viewModel;
  final double spaceBetween = 5;

  const AgreementStep({required this.viewModel, super.key});

  void _showAgreementDialog(
    BuildContext context,
    String title,
    VoidCallback? onAgree,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => TermsDialog(
            dialogTitle: title,
            onAgree: onAgree, // 동의 처리 함수 전달
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            '환영합니다!',
            style: TextStyle(
              fontSize: 30,
              fontFamily: 'NanumSquare',
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            '회원 가입을 위해 약관에 동의해 주세요.',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'NanumSquare',
              fontWeight: FontWeight.w500,
              color: Color(0xff9f9f9f),
            ),
          ),
          const SizedBox(height: 25),

          CheckBoxList(
            termTitle: '모두 동의',
            onCheckBoxTap:
                () => viewModel.setAllAgreements(!viewModel.isRequiredAgreed),
            boolValue: viewModel.isRequiredAgreed,
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: spaceBetween,
            ),
            child: Divider(
              thickness: 2, // 선 두께
              color: Color(0xffdddddd), // 선 색상
              height: 16,
            ),
          ),

          CheckBoxList(
            termTitle: '[필수] 서비스 이용 약관 동의',
            onCheckBoxTap:
                () => viewModel.setAgreement(terms: !viewModel.agreedToTerms),
            boolValue: viewModel.agreedToTerms,
            onTermsTap:
                () => _showAgreementDialog(context, '서비스 이용 약관 동의', () {
                  viewModel.setAgreement(terms: true);
                }),
          ),

          SizedBox(height: spaceBetween),

          CheckBoxList(
            termTitle: '[필수] 개인정보 처리 약관 동의',
            onCheckBoxTap:
                () => viewModel.setAgreement(
                  privacy: !viewModel.agreedToPrivacyPolicy,
                ),
            boolValue: viewModel.agreedToPrivacyPolicy,
            onTermsTap:
                () => _showAgreementDialog(context, '개인정보 처리 약관 동의', () {
                  viewModel.setAgreement(privacy: true);
                }),
          ),

          SizedBox(height: spaceBetween),

          CheckBoxList(
            termTitle: '[필수] 결제 이용 약관 동의',
            onCheckBoxTap:
                () =>
                    viewModel.setAgreement(payment: !viewModel.agreedToPayment),
            boolValue: viewModel.agreedToPayment,
            onTermsTap:
                () => _showAgreementDialog(context, '결제 이용 약관 동의', () {
                  viewModel.setAgreement(payment: true);
                }),
          ),

          // 필요시 약관 내용 보기 버튼 등 추가
        ],
      ),
    );
  }
}
