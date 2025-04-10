import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/data/models/gym_info_model.dart';


class InfoTab extends StatelessWidget{
  final GymInfo gymInfo;
  const InfoTab({super.key , required this.gymInfo});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("체육관 이름: ${gymInfo.name}", style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        const Text("hi"), // 여기에 실제 예약 정보 넣으면 됨
      ],
    );
  }

}