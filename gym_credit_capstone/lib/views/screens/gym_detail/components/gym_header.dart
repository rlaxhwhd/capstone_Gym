import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:gym_credit_capstone/view_models/gym_detail_view_model.dart';

import '../../../common_widgets/custom_back_button.dart';
import '../../../common_widgets/round_button_style.dart';

class GymHeader extends StatelessWidget {
  final String imageUrl;
  final double imageHeight;

  const GymHeader({
    super.key,
    required this.imageUrl,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
            const Center(child: Text("이미지를 불러올 수 없습니다.")),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 28,
          child: CustomBackButton(),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 28,
          child: RoundButtonStyle(
            child: IconButton(
              icon: Icon(
                Icons.share,
                color: const Color(0xff69B7FF),
              ),
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: "https://naver.com"));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("링크가 복사되었습니다!")),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

}