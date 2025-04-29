import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/view_models/gym_booking_view_model.dart';
import 'package:gym_credit_capstone/data/repositories/gym_info_repository.dart';
import '../../screens/gym_booking/payment_page.dart';

class GymBookingPage extends StatefulWidget {
  final String gymId;
  final List<String> selectedSports;

  const GymBookingPage({super.key, required this.gymId, required this.selectedSports});

  @override
  State<GymBookingPage> createState() => _GymBookingPageState();
}

class _GymBookingPageState extends State<GymBookingPage> {
  final GymInfoRepository _model = GymInfoRepository();
  late GymBookingViewModel? viewModel;
  Map<String, int> reservationCounts = {}; // 🔹 특정 날짜의 예약 데이터를 저장
  String gymAbbreviation = "UnknownGym"; // 🔹 체육관 약자 저장
  String formattedDate = "0000-00-00";
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
      List<String> availableTimes = viewModel!.generateAvailableTimes(
          operatingHours["start"]!, operatingHours["end"]!
      );

      viewModel!.fetchNext7Days(); // 🔹 자동으로 오늘부터 7일 적용

      viewModel!.setCallCheckReservations(checkReservations);

      // 🔹 ViewModel에서 예약 가능한 시간을 운영시간을 반영하여 업데이트
      viewModel!.updateAvailableTimes(availableTimes);

      // 🔹 종목 정보 업데이트
      viewModel!.calculateSportsSummary(widget.gymId, widget.selectedSports);

      // 🔹 Firestore에서 체육관 약자 가져오기
      print("gymId: ${widget.gymId}");
      gymAbbreviation = await _model.fetchGymAbbreviation(widget.gymId);
      print("약자 추출 완료 => $gymAbbreviation");

      setState(() {}); // 🔹 UI 업데이트
    });
  }

  Future<void> checkReservations(DateTime selectedDate) async {
    setState(() {
      isCheckingReservation = true;
    });

    formattedDate = "${selectedDate.toIso8601String().split('T')[0]}";

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 🔹 Firestore에서 체육관 운영시간 가져오기
    Map<String, String> operatingHours = await fetchOperatingHours(widget.gymId);
    String startTime = operatingHours["start"] ?? "00:00";
    String endTime = operatingHours["end"] ?? "23:59";
    List<String> allowedTimes = viewModel!.generateAvailableTimes(startTime, endTime);

    // 🔹 Firestore에서 예약된 문서 가져오기
    final QuerySnapshot querySnapshot = await firestore.collection('reservations').get();
    print("예약된 문서 개수: ${querySnapshot.docs.length}");

    reservationCounts = {}; // 예약 개수를 저장할 Map 초기화
    disabledTimes[formattedDate] = []; // 🔹 날짜 변경 시 비활성화 목록 초기화

    querySnapshot.docs.forEach((doc) {
      String docId = doc.id;
      List<String> parts = docId.split("_");

      if (parts.length >= 4 && DateTime.parse(doc.id.split('_')[0]) == selectedDate) {
        String timeSlot = parts[1]; // 🔹 시간 추출
        bool status = doc.get('status'); // 🔹 Firestore에서 status 값 가져오기

        if (status) { // 🔹 status가 true인 경우에만 카운트
          reservationCounts[timeSlot] = (reservationCounts[timeSlot] ?? 0) + 1;
        }
      }
    });

    reservationCounts.forEach((timeSlot, count) {
      if (count >= 5) { // 🔹 예약이 5개 이상이면 비활성화
        disabledTimes[formattedDate]?.add(timeSlot);
        print("[DEBUG] $formattedDate의 $timeSlot 비활성화: 예약 초과 ($count개 예약됨)");
      } else if (!allowedTimes.contains(timeSlot)) { // 🔹 운영시간 밖인 경우 비활성화
        disabledTimes[formattedDate]?.add(timeSlot);
        print("[DEBUG] $formattedDate의 $timeSlot 비활성화: 운영시간 ($startTime ~ $endTime) 밖");
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
                      onPressed:
                      viewModel.selectedDate != null
                          ? () {
                        formattedDate = "${viewModel.selectedDate!.toIso8601String().split('T')[0]}";

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentPage(
                              gymId: widget.gymId,
                              formattedDate: formattedDate,
                              selectedSport: viewModel.sportsSummary,
                              disabledTimes: disabledTimes,
                            ),
                          ),
                        );
                      }
                          : null,
                      child: const Text("결제하기"),
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
