import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/gym_booking_model.dart';

class GymBookingViewModel extends ChangeNotifier {
  final GymBookingModel _model = GymBookingModel();

  DateTime? selectedDate;
  String selectedTime = "";
  List<String> availableTimes = [];
  String userId = ""; // 현재 로그인된 사용자의 Firebase UID
  String sportsSummary = "";
  double totalPrice = 0.0;

  Future<void> fetchAvailableTimes(String gymId) async {
    final gymDetails = await _model.fetchGymDetails(gymId);
    if (gymDetails != null && gymDetails.containsKey('운영시간')) {
      String operatingHours = gymDetails['운영시간'];
      availableTimes = _generateAvailableTimeSlots(operatingHours);
      notifyListeners();
    }
  }

  Future<void> calculateSportsSummary(String gymId, List<String> selectedSports) async {
    final gymDetails = await _model.fetchGymDetails(gymId);

    if (gymDetails != null && gymDetails.containsKey('종목')) {
      Map<String, dynamic> categories = gymDetails['종목'];
      double total = 0.0;
      List<String> sportsList = [];

      for (String sport in selectedSports) {
        if (categories.containsKey(sport)) {
          total += double.parse(categories[sport]?.toString() ?? "0");
          sportsList.add(sport);
        }
      }

      totalPrice = total;
      sportsSummary = sportsList.join(', ');
      notifyListeners();
    }
  }

  Future<void> saveReservation(String gymId) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await _model.saveReservationToFirestore(gymId, user.uid, selectedDate!, selectedTime, sportsSummary, totalPrice);
    } else {
      print("로그인된 사용자가 없습니다."); // 사용자 미로그인 상태 출력
    }
  }

  void updateSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void updateSelectedTime(String time) {
    selectedTime = time;
    notifyListeners();
  }

  List<String> _generateAvailableTimeSlots(String operatingHours) {
    final times = operatingHours.split('~');
    final startTime = int.parse(times[0].split(':')[0]);
    final endTime = int.parse(times[1].split(':')[0]);

    List<String> timeSlots = [];
    final now = DateTime.now();

    for (int i = startTime; i <= endTime; i++) {
      DateTime slotTime = DateTime(now.year, now.month, now.day, i);

      if (slotTime.isAfter(now)) {
        String time = i.toString().padLeft(2, '0') + ':00';

        if (time != '12:00') {
          timeSlots.add(time);
        }
      }
    }
    return timeSlots;
  }
}