import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/views/screens/gym_booking/gym_booking_page.dart';

class GymBookingButton extends StatelessWidget {
  final String gymId;
  final List<String> selectedSports; // 선택된 종목 리스트를 전달받는 필드 추가

  const GymBookingButton({super.key, required this.gymId, required this.selectedSports});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(30, 12, 30, 23),
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff69B7FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GymBookingPage(
                gymId: gymId,
                selectedSports: selectedSports, // 선택된 종목 리스트 전달
              ),
            ),
          );
        },
        child: const Text(
          '예약하기',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}