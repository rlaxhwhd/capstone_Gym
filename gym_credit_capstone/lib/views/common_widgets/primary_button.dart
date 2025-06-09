import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/style/custom_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 0,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 20, color: onPressed == null ? Color(0xFF707070) : Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
