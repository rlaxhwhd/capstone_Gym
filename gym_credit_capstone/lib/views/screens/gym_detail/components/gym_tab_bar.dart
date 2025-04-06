import 'package:flutter/material.dart';

class GymTabBar extends StatelessWidget{
  const GymTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      labelColor: Color(0xff69B7FF),
      unselectedLabelColor: Color(0xff191919),
      indicatorColor: Color(0xff69B7FF),
      indicatorWeight: 5,
      labelStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      tabs: [
        Tab(text: '예약 정보'),
        Tab(text: '지도'),
        Tab(text: '준수 사항'),
      ],
    );
  }
}