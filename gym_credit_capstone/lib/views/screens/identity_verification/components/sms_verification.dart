import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gym_credit_capstone/view_models/identity_verification_view_model.dart';
import 'package:gym_credit_capstone/views/common_widgets/primary_button.dart';
import 'package:gym_credit_capstone/views/common_widgets/labeled_text_row.dart';
import 'package:url_launcher/url_launcher.dart';

class SmsVerification extends StatelessWidget {
  final IdentityVerificationViewModel viewModel;

  const SmsVerification({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 28),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Text(
              '기기인증 안내',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'NanumSquare',
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            LabeledTextRow(
              labelType: LabelType.numType,
              textList: [
                '하단 [인증 메시지 보내기]를 눌러주세요.',
                "메시지 작성 창에서, 인증 메시지가 자동으로 입력되어 있습니다.",
                "인증메시지를 그대로 보내주세요.",
                "전송 완료 후 [메시지 전송 완료]버튼을 눌러 인증을 완료해주세요",
              ],
            ),
            const SizedBox(height: 30),

            // 이미지 영역에 AspectRatio를 적용하여 명확한 높이 제약조건을 부여합니다.
            // SvgPicture가 가로 길이에 맞춰 세로 길이를 유지하도록 합니다.
            AspectRatio(
              aspectRatio: 94.192 / 61.473, // 실제 이미지 비율을 계산하여 입력
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/sms_verification2.svg',
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 7),
            LabeledTextRow(
              labelType: LabelType.textSmall,
              textList: [
                '이용 중인 통신 요금제에 따라 문자 메시지 발송 비용이 청구될 수 있습니다.'
              ],
              textStyle: const TextStyle(
                fontSize: 17,
                fontFamily: 'NanumSquare',
                color: Colors.grey,
              ),
              labelStyle: const TextStyle(fontSize: 17),
            ),
            //const SizedBox(height: 25),

          ],
        ),
    );
  }
}