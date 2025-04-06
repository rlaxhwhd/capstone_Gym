import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/background_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BackgroundImg extends StatelessWidget {
  const BackgroundImg({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double finalHeight = screenWidth * (163 / 393);

    // 상태 표시줄 높이 가져오기
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      context.read<BackgroundViewModel>().loadNickname(user.uid);
    }

    return SizedBox(
      height: finalHeight + statusBarHeight, // 상태 표시줄 높이를 추가
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
                height: finalHeight + statusBarHeight, // 높이 조정
              ),
            ),
          ),
          // 닉네임 텍스트 위치 조정
          Positioned(
            top: statusBarHeight + 30, // 상태 표시줄 높이를 고려하여 조정
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