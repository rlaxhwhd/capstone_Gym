import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/gym_info_repository.dart';
import '../data/models/gym_booking_model.dart';

class GymBookingViewModel extends ChangeNotifier {
  final GymInfoRepository _model = GymInfoRepository();
  final GymBookingModel _bookingModel = GymBookingModel();
  int selectedDay = 0;
  int selectedDayIndex = -1;
  final List<String> weekDays = ['일', '월', '화', '수', '목', '금', '토'];
  List<DateTime> weekDates = [];

  int todayIndex = DateTime.now().weekday % 7;

  late Function(DateTime) callCheckReservations;

  DateTime? selectedDate;
  String selectedTime = "";
  List<DateTime> availableDates = []; // 🔹 예약 가능한 날짜 리스트 추가
  List<String> availableTimes = [];
  String userId = ""; // 현재 로그인된 사용자의 Firebase UID
  String sportsSummary = "";
  double totalPrice = 0.0;

  DocumentSnapshot? gymSnapshot;

  void selectDay(int dayIndex, int day) {
    selectedDayIndex = dayIndex;
    selectedDay = day;
    notifyListeners();
  }

  Future<void> generateWeekDates() async {
    DateTime now = DateTime.now();
    weekDates = List.generate(7, (index) => now.add(Duration(days: index)));
    print("[DEBUG BOOKING VIEW MODEL] weekDates: ${weekDates}");
    notifyListeners();
  }

  List<String> generateAvailableTimes(String startTime, String endTime) {
    DateTime start = DateTime.parse("2025-01-01 $startTime:00");
    DateTime end = DateTime.parse("2025-01-01 $endTime:00");

    print("가능한 시간 찾기");

    List<String> availableTimes_list = [];
    while (start.isBefore(end) || start.isAtSameMomentAs(end)) {
      availableTimes_list.add("${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}");
      start = start.add(Duration(hours: 1)); // 🔹 한 시간 단위로 증가
    }

    availableTimes = availableTimes_list;

    return availableTimes_list;
  }

  void setCallCheckReservations(Function(DateTime) callback) {
    callCheckReservations = callback;
  }

  void updateSelectedDate(DateTime date) {
    selectedDate = date; // 🔹 클래스 멤버 변수 업데이트

    print("[DEBUG BOOKING VIEW MODEL] 선택된 날짜: ${selectedDate}"); // 🔹 디버깅용 로그 추가

    if (selectedDate != null) { // 🔹 null 체크 추가
      print("[DEBUG BOOKING VIEW MODEL] 시간 확인 호출");

      fetchReservations(selectedDate!); // 🔹 Firestore 데이터 가져오기
      callCheckReservations(selectedDate!); // 🔹 날짜 변경 후 예약 확인 실행
      notifyListeners(); // 🔹 UI 업데이트 반영
    } else {
      print("[ERROR BOOKING VIEW MODEL] 선택된 날짜가 null입니다.");
    }
  }

  void fetchNext7Days() {
    List<DateTime> next7Days = List.generate(7, (index) {
        DateTime date = DateTime.now().toUtc().add(Duration(hours: 9)).add(Duration(days: index));
        return DateTime(date.year, date.month, date.day); // 🔹 시간 제거
      }
    ); // 🔹 한국 시간 기준 오늘부터 7일 생성

    print("한국 시간 기준 오늘부터 7일 생성");

    updateAvailableDates(next7Days); // 🔹 자동 호출
  }

  void updateAvailableDates(List<DateTime> dates) {
    availableDates = dates;

    print("[DEBUG] dates: ${dates}");
    print("[DEBUG] 입력된 날짜 (시간 제거됨): ${dates.map((date) => date.toIso8601String().split('T')[0])}");

    notifyListeners(); // 🔹 UI 업데이트 반영
  }

  void updateAvailableTimes(List<String> times) {
    //List<String> availableTimes = []; // 🔹 예약 가능한 시간을 저장하는 리스트

    availableTimes = times; // 🔹 새로운 운영시간 반영
    notifyListeners(); // 🔹 UI 업데이트
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

  String formatDateTimeKST(DateTime dateTime) {
    // UTC+9 시간대로 변환
    DateTime kstTime = dateTime.toUtc().add(Duration(hours: 9));

    // 날짜 및 시간 포맷 설정
    String year = "${kstTime.year}년";
    String month = "${kstTime.month.toString().padLeft(2, '0')}월";
    String day = "${kstTime.day.toString().padLeft(2, '0')}일";

    // 오전/오후 설정
    String period = kstTime.hour < 12 ? "AM" : "PM";

    // 12시간제 적용
    int hour = kstTime.hour % 12 == 0 ? 12 : kstTime.hour % 12;
    String minute = "${kstTime.minute.toString().padLeft(2, '0')}분";
    String second = "${kstTime.second.toString().padLeft(2, '0')}초";

    return "$year $month $day $period $hour시 $minute $second UTC+9";
  }

  //예약 정보 저장
  Future<bool> saveReservation(
      String gymId
      , Map<String, List<String>> disabledTimes
      , String selectedTime
      , String formattedDate) async {
    final user = FirebaseAuth.instance.currentUser;

    DocumentSnapshot? gymSnapshot;

    print("[DEBUG_VIEW_MODEL]" + disabledTimes.length.toString() + "_" + selectedTime);

    for(int i = 0; i < disabledTimes.length; i++) {
      if (disabledTimes.containsKey(formattedDate) && i < disabledTimes[formattedDate]!.length
      && disabledTimes[formattedDate]![i] == selectedTime) {
        print("[DEBUG_VIEW_MODEL_FOR] " + disabledTimes[formattedDate]![i] + "_" + selectedTime);

        print("[DEBUG_VIEW_MODEL_FOR] 예약을 해선 안됨");
        return false;
      }
    }

    try {
      gymSnapshot = await FirebaseFirestore.instance.collection('Gym_list').doc(gymId).get();

      String translatedSportsName = _bookingModel.translateSportsSummary(sportsSummary);

      if (gymSnapshot.exists) {
        String gymAbbreviation = gymSnapshot.get("약자");

        // 현재 선택된 종목의 가격 가져오기
        Map<String, dynamic> sportsData = gymSnapshot.get("종목");
        int price = sportsData[sportsSummary] ?? 0; // 해당 종목이 없으면 기본값 0 설정

        // 현재 시간 UTC+9로 변환 및 포맷 적용
        String formattedCreateTime = formatDateTimeKST(DateTime.now());

        // 날짜를 "YYYY-MM-DD" 형식으로 변환
        String formattedDate = "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

        // 직접 데이터 항목 지정
        Map<String, dynamic> reservationData = {
          "createtime": formattedCreateTime, // 생성 시간
          "date": formattedDate, // 날짜 (00:00:00.000 제거됨)
          "gymId": gymId, // 체육관 ID
          "gymAbbreviation": gymAbbreviation, // 체육관 약어
          "sports": {
            "price": price, // 가격
            "sportName": translatedSportsName, // 운동 종목
          },
          "status": true, // 상태
          "time": selectedTime, // 선택 시간
          "userId": user!.uid // 사용자 ID
        };

        // 직접 지정한 항목을 Firestore에 저장
        String formattedDocName = "${formattedDate}_${selectedTime}_${gymAbbreviation}_${translatedSportsName}_${user.uid}";
        await FirebaseFirestore.instance.collection('reservations').doc(formattedDocName).set(reservationData);

        return true;
      } else {
        print('체육관 데이터를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('체육관 데이터를 불러오는 중 오류 발생: $e');
    }

    return false;
  }

  void updateSelectedTime(String time) {
    selectedTime = time;
    notifyListeners();
  }

  Future<void> fetchReservations(DateTime selectedDate) async {
    final querySnapshot = await FirebaseFirestore.instance.collection('reservations')
        .where("date", isEqualTo: selectedDate) // 🔹 DateTime 그대로 비교
        .get();

    if (querySnapshot.docs.isEmpty) {
      print("[ERROR] 선택한 날짜의 예약 데이터를 찾을 수 없음");
    } else {
      querySnapshot.docs.forEach((doc) {
        print("[DEBUG] 선택한 날짜의 예약 데이터: ${doc.id}");
      });
    }
  }
}
