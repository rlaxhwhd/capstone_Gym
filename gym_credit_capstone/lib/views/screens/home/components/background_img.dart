import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/background_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_credit_capstone/data/repositories/auth_repository.dart';

class BackgroundImg extends StatelessWidget {
  final double imageHeight;

  const BackgroundImg({
    super.key,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery
        .of(context)
        .padding
        .top;
    final authRepository = AuthRepository();
    final user = authRepository.getCurrentUserId();

    if (user != null) {
      context.read<BackgroundViewModel>().loadNickname(user);
    }

    return Stack(
      children: [
        SizedBox(
          height: imageHeight, // 상태 표시줄 높이 추가
          width: double.infinity,
          child: Image.asset(
            'assets/images/Home_background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Center(child: Text("이미지를 불러올 수 없습니다.")),
          ),
        ),
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
    );
  }
}