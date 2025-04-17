import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/view_models/gym_booking_view_model.dart';
import 'package:gym_credit_capstone/data/models/gym_booking_model.dart';
import 'package:gym_credit_capstone/data/repositories/gym_info_repository.dart';

class GymBookingPage extends StatefulWidget {
  final String gymId;
  final List<String> selectedSports;

  const GymBookingPage({super.key, required this.gymId, required this.selectedSports});

  @override
  State<GymBookingPage> createState() => _GymBookingPageState();
}

class _GymBookingPageState extends State<GymBookingPage> {
  final GymInfoRepository _model = GymInfoRepository();
  final GymBookingModel _bookingModel = GymBookingModel();
  late GymBookingViewModel viewModel;
  Map<String, int> reservationCounts = {}; // 🔹 특정 날짜의 예약 데이터를 저장
  String gymAbbreviation = "UnknownGym"; // 🔹 체육관 약자 저장
  bool isProcessing = false;
  bool isCheckingReservation = false; // 🔹 예약 확인 중일 때 시간 선택 버튼 비활성화
  Map<String, List<String>> disabledTimes = {}; // 🔹 날짜별 비활성화된 시간 저장

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      viewModel = Provider.of<GymBookingViewModel>(context, listen: false);

      // 🔹 Firestore에서 운영시간 가져오기
      Map<String, String> operatingHours = await fetchOperatingHours(widget.gymId);

      // 🔹 운영시간을 기반으로 예약 가능한 시간 생성
      List<String> availableTimes = viewModel.generateAvailableTimes(
          operatingHours["start"]!, operatingHours["end"]!
      );

      viewModel.fetchNext7Days(); // 🔹 자동으로 오늘부터 7일 적용

      viewModel.setCallCheckReservations(checkReservations);

      // 🔹 ViewModel에서 예약 가능한 시간을 운영시간을 반영하여 업데이트
      viewModel.updateAvailableTimes(availableTimes);

      // 🔹 종목 정보 업데이트
      viewModel.calculateSportsSummary(widget.gymId, widget.selectedSports);

      // 🔹 Firestore에서 체육관 약자 가져오기
      print("gymId: ${widget.gymId}");
      gymAbbreviation = await _model.fetchGymAbbreviation(widget.gymId);
      print("약자 추출 완료 => $gymAbbreviation");

      setState(() {}); // 🔹 UI 업데이트
    });
  }

  //특정 날짜를 선택 했을 때 작동
  Future<void> checkReservations(DateTime selectedDate) async {
    setState(() {
      isCheckingReservation = true;
    });

    final viewModel = Provider.of<GymBookingViewModel>(context, listen: false);
    String formattedDate = "${selectedDate.toIso8601String().split('T')[0]}";

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 🔹 Firestore에서 체육관 운영시간 가져오기
    Map<String, String> operatingHours = await fetchOperatingHours(widget.gymId);
    String startTime = operatingHours["start"] ?? "00:00";
    String endTime = operatingHours["end"] ?? "23:59";
    List<String> allowedTimes = viewModel.generateAvailableTimes(startTime, endTime); // 🔹 운영시간에 따른 예약 가능 시간 생성

    // 🔹 예약된 문서를 정확하게 조회 (전체 키 구조 반영)
    final QuerySnapshot querySnapshot = await firestore.collection('reservations')
        .get(); // 🔹 전체 예약 문서 조회 (필터링을 없앰)

    print("예약된 문서 개수: ${querySnapshot.docs.length}");

    // 🔹 각 시간의 예약 개수를 저장 (문서 ID만 비교)
    reservationCounts = {};

    if (querySnapshot.docs.isNotEmpty) { // 🔹 문서가 존재할 때만 실행
      querySnapshot.docs.forEach((doc) {
        String docId = doc.id;
        List<String> parts = docId.split("_");

        if (parts.length >= 4) { // 🔹 잘못된 인덱스 접근 방지
          String timeSlot = parts[1]; // 🔹 시간 추출
          reservationCounts[timeSlot] = (reservationCounts[timeSlot] ?? 0) + 1; // 🔹 값이 없으면 0으로 초기화
        }
      });
    }

    print("예약 데이터 확인: $reservationCounts");
    print("예약 가능한 시간 목록: ${viewModel.availableTimes}"); // 🔹 availableTimes 출력
    print("비활성화된 시간 목록: ${disabledTimes[viewModel.selectedDate?.toIso8601String().split('T')[0]]}"); // 🔹 disabledTimes 출력

    reservationCounts = {}; // 🔹 예약 개수 저장을 위한 Map 초기화

    querySnapshot.docs.forEach((doc) {
      String dateString = doc.id.split("_")[0]; // 🔹 날짜 부분만 추출

      try {
        DateTime parsedDate = DateTime.parse(dateString); // 🔹 String을 DateTime으로 변환
        print("[DEBUG] Firestore에서 변환된 날짜: $parsedDate");
      } catch (e) {
        print("[ERROR] 날짜 변환 실패: $dateString / 오류: $e");
      }
    });

    querySnapshot.docs.forEach((doc) {
      String docId = doc.id;
      List<String> parts = docId.split("_");

      if (parts.length >= 4) { // 🔹 날짜와 시간, 종목까지 포함해야 함
        String dateSlot = parts[0]; // 🔹 날짜 추출
        String timeSlot = parts[1]; // 🔹 시간 추출
        String sportAbbreviation = parts[3]; // 🔹 종목 약자 추출
        String dateTimeSportKey = "${dateSlot}_${timeSlot}_${sportAbbreviation}"; // 🔹 날짜 + 시간 + 종목 조합

        reservationCounts[dateTimeSportKey] = (reservationCounts[dateTimeSportKey] ?? 0) + 1;
      }
    });

    // 🔹 날짜별 비활성화된 시간 저장 (운영시간을 고려하여 업데이트)
    disabledTimes[formattedDate] = [];

    reservationCounts.forEach((dateTimeSportKey, count) {
      List<String> parts = dateTimeSportKey.split("_");

      if (parts.length >= 3) {
        String dateSlot = parts[0];
        String timeSlot = parts[1];
        String sportAbbreviation = parts[2];

        if (dateSlot == formattedDate && sportAbbreviation == _bookingModel.translateSportsSummary(widget.selectedSports.join(", "))) { // 🔹 현재 선택한 날짜 + 종목에 대해서만 검사
          if (count >= 5) { // 🔹 예약이 5개 이상이면 비활성화
            disabledTimes[formattedDate]?.add(timeSlot);
            print("[DEBUG] 날짜 $formattedDate의 시간 $timeSlot 비활성화: 종목 '$sportAbbreviation' 예약 초과 ($count개 예약됨)");
          } else if (!allowedTimes.contains(timeSlot)) { // 🔹 운영시간 밖인 경우 비활성화
            disabledTimes[formattedDate]?.add(timeSlot);
            print("[DEBUG] 날짜 $formattedDate의 시간 $timeSlot 비활성화: 운영시간 ($startTime ~ $endTime) 밖");
          } else {
            print("[DEBUG] 날짜 $formattedDate의 시간 $timeSlot 정상 예약 가능!");
          }
        }
      }
    });

    setState(() {
      isCheckingReservation = false;
    });
  }

  Future<Map<String, String>> fetchOperatingHours(String gymId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot doc = await firestore.collection('Gym_list').doc(gymId).get();

    if (doc.exists) {
      Map<String, dynamic> gymData = doc.data() as Map<String, dynamic>; // 🔹 Object → Map으로 변환
      String operatingHours = gymData['운영시간'] ?? "00:00~23:59"; // 🔹 운영시간 필드 가져오기
      List<String> hours = operatingHours.split("~"); // 🔹 시작~종료 시간 분리

      print("운영시간: ${operatingHours}");
      print("운영시간: ${hours}");

      return {"start": hours[0], "end": hours[1]};
    }

    print("운영시간: 불러오기 실패");
    
    return {"start": "00:00", "end": "23:59"};
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GymBookingViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(title: Text("${widget.gymId} 예약 페이지")),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ 날짜 선택 UI
                  Text("예약 가능한 날짜를 선택하세요:", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: viewModel.availableDates.map((date) {
                      bool isSelected = viewModel.selectedDate == date;
                      return ElevatedButton(
                        onPressed: () {
                          viewModel.updateSelectedDate(date);
                          print("[DEBUG] 선택된 날짜: $date");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.blue : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: Text(date.toIso8601String().split('T')[0]),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ✅ 시간 선택 UI
                  Text("예약 가능한 시간을 선택하세요:", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: viewModel.availableTimes.map((time) {
                      bool isSelected = viewModel.selectedTime == time;
                      DateTime nowKST = DateTime.now().toUtc().add(Duration(hours: 9));
                      DateTime selectedDate = viewModel.selectedDate ?? nowKST;
                      DateTime timeSlot = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
                          int.parse(time.split(":")[0]), int.parse(time.split(":")[1]));
                      bool isPastTime = timeSlot.isBefore(nowKST);
                      bool isDisabled = disabledTimes[selectedDate.toIso8601String().split('T')[0]]?.contains(time) ?? false;

                      return ElevatedButton(
                        onPressed: isCheckingReservation || isPastTime || isDisabled
                            ? null
                            : () async {
                          // 🔹 포커스 해제하여 다른 입력 필드 활성화 방지
                          FocusScope.of(context).unfocus();

                          // 🔹 시간 선택 중 로딩 다이얼로그 표시
                          showDialog(
                            context: context,
                            barrierDismissible: false, // 사용자가 닫을 수 없도록 설정
                            builder: (context) {
                              return AlertDialog(
                                content: Row(
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(width: 20),
                                    Text("시간 정보를 확인하는 중..."),
                                  ],
                                ),
                              );
                            },
                          );

                          // 🔹 비동기 작업 실행 (예약 시간 업데이트)
                          await Future.delayed(Duration(milliseconds: 500)); // 🔹 UI 테스트용 지연 시간

                          viewModel.updateSelectedTime(time);

                          print("[DEBUG] 선택된 시간: $time (KST)");

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("선택된 시간: $time (KST)")),
                              );
                            }
                          });

                          // 🔹 로딩 다이얼로그 닫기
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.blue : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: Text(time),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ✅ 예약 버튼
                  Center(
                    child: ElevatedButton(
                      onPressed: (viewModel.selectedDate != null && viewModel.selectedTime.isNotEmpty && !isProcessing)
                          ? () async {
                        setState(() {
                          isProcessing = true;
                        });

                        await viewModel.saveReservation(widget.gymId);

                        setState(() {
                          isProcessing = false;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("예약이 완료되었습니다!")));
                      }
                          : null,
                      child: const Text("예약하기"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}