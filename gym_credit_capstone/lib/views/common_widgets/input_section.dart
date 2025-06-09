import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/views/common_widgets/searchPostcodePage.dart';

import 'package:gym_credit_capstone/style/custom_colors.dart';

class InputSectionWidget extends StatelessWidget {
  final String title;
  final Widget child;
  final String? subtitle;
  final String? errorMessage;
  final double spaceBetween;
  final ValueChanged<String>? streetAddressResult;
  final Color? titleColor;
  final String? fontFamily;

  const InputSectionWidget({
    Key? key,
    required this.title,
    required this.child,
    this.subtitle,
    this.errorMessage,
    this.spaceBetween = 20.0,
    this.streetAddressResult,
    this.titleColor,
    this.fontFamily = 'NanumSquare',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: fontFamily,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: titleColor ?? Colors.grey.shade800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            Spacer(),
            if (title == "주소")
              Container(
                width: 150,
                height: 32,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SearchPostcodePage()),
                    );
                    if (result != null) {
                      // ViewModel의 메서드를 사용해서 주소 설정
                      streetAddressResult?.call(result.address);
                    }
                    FocusScope.of(context).unfocus();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: CustomColors.primaryColor,
                    elevation: 0,
                    side: BorderSide(
                      color: CustomColors.primaryColor,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '도로명 주소 검색',
                        style: TextStyle(
                          fontFamily: 'NanumSquare',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: title == "주소" ? 20 : 5),
        child,
        // 에러 메시지 표시
        if (errorMessage != null) ...[
          const SizedBox(height: 5),
          Text(
            errorMessage!,
            style: TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.red,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
        SizedBox(
          height: errorMessage != null ? spaceBetween - 15 : spaceBetween,
        ),
      ],
    );
  }
}
