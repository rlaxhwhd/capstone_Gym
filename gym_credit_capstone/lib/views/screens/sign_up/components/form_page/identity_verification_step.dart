import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/view_models/sign_up_view_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gym_credit_capstone/style/custom_colors.dart';
import 'package:gym_credit_capstone/views/screens/identity_verification/identity_verification.dart';

class IdentityVerificationStep extends StatefulWidget {
  final SignUpViewModel viewModel;

  const IdentityVerificationStep({required this.viewModel, super.key});

  @override
  State<IdentityVerificationStep> createState() =>
      _IdentityVerificationStepState();
}

class _IdentityVerificationStepState extends State<IdentityVerificationStep> {


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            '본인 확인을 위해\n인증을 진행해 주세요.',
            style: TextStyle(
              fontSize: 30,
              fontFamily: 'NanumSquare',
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            '아래 항목을 눌러 본인인증을 해주세요.',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'NanumSquare',
              fontWeight: FontWeight.w500,
              color: Color(0xff9f9f9f),
            ),
          ),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: () async {
              if (!widget.viewModel.isTelVerified) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IdentityVerification(),
                  ),
                );

                // 결과가 있을 경우에만 처리
                if (result != null && result is Map<String, dynamic>) {
                  widget.viewModel.setVerifiedPhoneNumber(result['phoneNumber'], result['isVerified']);
                  widget.viewModel.valuableState();

                }
              }
            },
            child: Container(
              width: double.infinity,
              height: 120,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      widget.viewModel.isTelVerified
                          ? CustomColors.primaryColor
                          : Colors.grey.withOpacity(0.5),
                  width: 1.7,
                ),
                boxShadow: [
                  // 그림자 효과를 위한 boxShadow 리스트
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // 그림자 색상 및 투명도
                    spreadRadius: 1, // 그림자가 퍼지는 정도
                    blurRadius: 5, // 그림자의 흐림 정도
                    offset: const Offset(1, 2), // 그림자의 위치 (가로, 세로) - 아래로 3픽셀 이동
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 18),
                  SvgPicture.asset(
                    'assets/images/phone_img.svg',
                    colorFilter: ColorFilter.mode(
                      widget.viewModel.isTelVerified ? CustomColors.primaryColor : Colors.grey,
                      BlendMode.srcIn, // 원본 이미지의 투명한 부분은 유지하고 색상을 입힙니다.
                    ),
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.viewModel.isTelVerified ? "전화번호로 인증 완료" : "전화번호로 인증하기",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'NanumSquare',
                        ),
                      ),
                      Text(
                        widget.viewModel.isTelVerified
                            ? "본인 명의 전화번호로 인증완료 됐어요."
                            : "본인 명의 전화번호로 인증해주세요.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'NanumSquare',
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Transform.scale(
                      scale: 1.5,
                      child: AbsorbPointer(
                        absorbing: true, // 터치 이벤트를 막음
                        child: Checkbox(
                          value: widget.viewModel.isTelVerified,
                          onChanged: (bool? newValue) {},
                          activeColor: CustomColors.primaryColor,
                          // 또는 const Color(0xff69B7FF)
                          checkColor: Colors.white,
                          side: BorderSide(
                            color:
                                widget.viewModel.isTelVerified
                                    ? CustomColors.primaryColor
                                    : Colors.grey,
                          ),
                          // 또는 const Color(0xff69B7FF)
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
