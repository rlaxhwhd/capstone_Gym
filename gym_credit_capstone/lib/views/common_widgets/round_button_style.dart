import 'package:flutter/material.dart';

class RoundButtonStyle extends StatelessWidget {
  final Widget child;

  const RoundButtonStyle({super.key, required this.child});

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
      child: child,
    );
  }
}
