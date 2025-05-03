import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/data/models/schedule_model.dart';
import 'package:gym_credit_capstone/data/repositories/schedule_repository.dart';
import 'package:gym_credit_capstone/data/repositories/auth_repository.dart';

class ScheduleViewModel extends ChangeNotifier {
  final ScheduleRepository _repository = ScheduleRepository();
  List<Reservation> reservations = [];
  int selectedDay = 0;
  int selectedDayIndex = -1;
  final List<String> weekDays = ['일', '월', '화', '수', '목', '금', '토'];
  List<DateTime> weekDates = [];

  final AuthRepository authRepository = AuthRepository(); // 🔥 객체 생성
  String userId = ''; // 🔥 초기값 설정

  ScheduleViewModel() {
    _initializeUserId(); // 🔥 생성자에서 사용자 ID 초기화
    generateWeekDates();
  }

  void _initializeUserId() {
    userId = authRepository.getCurrentUserId() ?? ''; // 🔥 Firebase에서 현재 로그인된 사용자 ID 가져오기
    notifyListeners(); // 🔥 UI 갱신
  }

  // 🔥 오늘 요일 인덱스 추가
  int todayIndex = DateTime.now().weekday % 7;

  void generateWeekDates() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    weekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    notifyListeners();
  }

  Future<void> loadReservations(String userId) async {
    reservations = await _repository.fetchScheduleReservations(userId);

    // 🔥 예약 데이터를 명확하게 출력
    for (var reservation in reservations) {
      print("[DEBUG VIEW MODEL] 예약: 날짜 - ${reservation.date}, 시간 - ${reservation.time}, 장소 - ${reservation.gymId}");
    }

    notifyListeners();
  }

  void selectDay(int dayIndex, int day) {
    selectedDayIndex = dayIndex;
    selectedDay = day;
    notifyListeners();
  }

  // 🔥 선택된 날짜에 예약이 있는지 확인하는 기능 추가
  bool checkScheduleReservations() {
    if (selectedDayIndex < 0) return false;

    DateTime selectedWeekDate = weekDates[selectedDayIndex];
    String formattedDate = '${selectedWeekDate.year}-${selectedWeekDate.month.toString().padLeft(2, '0')}-${selectedWeekDate.day.toString().padLeft(2, '0')}';

    print("[DEBUG VIEW MODEL]: ${selectedWeekDate}");
    print("[DEBUG VIEW MODEL]: ${reservations}");

    bool hasReservation = reservations.any((reservation) {
      return reservation.docId.contains(formattedDate); // 🔥 contains() 방식으로 변경
    });

    print("[DEBUG VIEW MODEL]: hasReservation: ${hasReservation}");
    return hasReservation;
  }

  void showCancelDialog(BuildContext context, String docId, String reservationTime) {
    DateTime now = DateTime.now().toUtc().add(const Duration(hours: 9)); // 🔥 한국 시간으로 변환
    List<String> timeParts = reservationTime.split(':'); // 🔥 '14:00'을 ['14', '00']로 분리
    DateTime reservationDateTime = DateTime(now.year, now.month, now.day, int.parse(timeParts[0]), int.parse(timeParts[1])); // 🔥 변환

    // 🔥 예약 시간이 1시간 미만이면 취소 불가능 메시지 표시
    if (reservationDateTime.difference(now).inMinutes < 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("예약 시간이 1시간 미만이면 예약 취소가 불가능합니다."),
          duration: Duration(seconds: 2),
        ),
      );
      return; // 🔥 취소 중단
    }

    // 🔥 1시간 이상 남았으면 확인 다이얼로그 표시
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("예약 취소 확인"),
          content: const Text("정말 예약을 취소하시겠습니까?"),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // 🔥 '아니요' 클릭 → 닫기
              child: const Text("아니요", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 🔥 다이얼로그 닫기
                cancelReservation(context, docId); // 🔥 예약 취소 실행
              },
              child: const Text("예", style: TextStyle(color: Colors.red),),
            ),
          ],
        );
      },
    );
  }

  void cancelReservation(BuildContext context, String docId) {
    reservations = reservations.map((reservation) {
      if (reservation.docId == docId) {
        return Reservation(
          docId: reservation.docId,
          date: reservation.date,
          time: reservation.time,
          gymId: reservation.gymId,
          status: false, // 🔥 상태 변경
        );
      }
      return reservation;
    }).toList();

    final ScheduleRepository sr = ScheduleRepository();

    sr.cancelScheduleReservation(docId);

    notifyListeners(); // 🔥 UI 갱신

    // 🔥 예약 취소 후 화면 하단에 알림 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("예약이 취소되었습니다."),
        duration: const Duration(seconds: 2), // 🔥 2초 후 자동 사라짐
      ),
    );
  }
}