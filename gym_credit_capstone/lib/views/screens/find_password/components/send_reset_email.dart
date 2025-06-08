import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/view_models/find_password_view_model.dart';

import 'package:gym_credit_capstone/views/common_widgets/input_section.dart';
import 'package:gym_credit_capstone/views/common_widgets/CustomInputLine.dart';

class SendResetEmail extends StatelessWidget {
  final FindPasswordViewModel viewModel;

  const SendResetEmail({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 28),
      child: Center(

        child: Column(
          children: [
            const SizedBox(height: 300),
            Text(
              '메일을 보냈습니다.',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'NanumSquare',
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '받은 메일에서 비밀번호를 변경해주세요.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'NanumSquare',
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
