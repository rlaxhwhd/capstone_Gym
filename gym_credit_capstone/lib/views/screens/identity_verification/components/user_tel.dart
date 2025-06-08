import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/view_models/identity_verification_view_model.dart';
import 'package:gym_credit_capstone/style/custom_colors.dart';
import 'package:gym_credit_capstone/views/common_widgets/CustomInputLine.dart';

class UserTel extends StatelessWidget {
  final IdentityVerificationViewModel viewModel;

  const UserTel({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            '전화번호를 입력해 주세요.',
            style: TextStyle(
              fontSize: 30,
              fontFamily: 'NanumSquare',
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            '국내 휴대폰 번호 10~11자리만 입력해 주세요.',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'NanumSquare',
              fontWeight: FontWeight.w500,
              color: Color(0xff9f9f9f),
            ),
          ),
          const SizedBox(height: 16),

          CustomInputLine(
            hintTextValue: '전화번호 입력',
            controller: viewModel.telController,
            inputValue: '전화번호',
            keyboardType: TextInputType.phone,
            onChanged: (value){
              bool telVerification = value.trim().isNotEmpty && viewModel.isValidPhoneNumber(value);
              viewModel.setTelStepCompleted(telVerification);
            },
          ),
        ],
      ),
    );
  }
}
