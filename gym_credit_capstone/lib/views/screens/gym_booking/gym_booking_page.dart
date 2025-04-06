import 'package:flutter/material.dart';

class GymBookingPage extends StatelessWidget {
  final String gymId;

  const GymBookingPage({super.key, required this.gymId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('$gymId 예약 페이지 입니다.')));
  }
}
