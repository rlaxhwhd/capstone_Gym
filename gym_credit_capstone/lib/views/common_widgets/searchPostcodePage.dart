import 'package:flutter/material.dart';
import 'package:daum_postcode_view/daum_postcode_view.dart';

// SearchPostcodePage.dart
class SearchPostcodePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DaumPostcodeView(
        onComplete: (model) {
          Navigator.of(context).pop(model); // 주소 결과를 되돌려줌
        },
      ),
    );
  }
}
