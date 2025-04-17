import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/views/screens/gym_booking/gym_booking_page.dart';
import 'package:gym_credit_capstone/views/screens/gym_booking/sports_select_page.dart';

class GymBookingButton extends StatelessWidget {
  final String gymId;

  const GymBookingButton({super.key, required this.gymId});

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
        onPressed: () async {
          final selectedSport = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SportsSelectionPage(gymId: gymId),
            ),
          );

          if (selectedSport != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GymBookingPage(
                  gymId: gymId,
                  selectedSports: [selectedSport], // 🔹 선택한 종목 전달
                ),
              ),
            );
          }
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