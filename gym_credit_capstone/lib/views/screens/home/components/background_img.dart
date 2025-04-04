import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/background_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BackgroundImg extends StatelessWidget {
  const BackgroundImg({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // 화면 너비
    double finalHeight = screenWidth * (163 / 393); // XD 기준 높이
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 닉네임 로드 요청
      context.read<BackgroundViewModel>().loadNickname(user.uid);
    }

    return SizedBox(
      height: finalHeight,
      width: screenWidth,
      child: Stack(
        children: [
          ClipRect(
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/Home_background.png",
                width: screenWidth,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 닉네임 텍스트 표시
          Positioned(
            top: 50,
            left: 25,
            child: Consumer<BackgroundViewModel>(
              builder: (context, viewModel, child) {
                final nickname = viewModel.nickname ?? '사용자';
                return Text(
                  '$nickname 님, 우리의 봄이 \n아름답게 피어나길 바라요!',
                  style: const TextStyle(
                    fontFamily: 'NanumSquare',
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff191919),
                    height: 1.8,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
