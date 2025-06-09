import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CustomBackButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2b2b2b).withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: const Color(0xff69B7FF)),
        onPressed: onPressed ?? () => Navigator.pop(context),
      ),
    );
  }
}
