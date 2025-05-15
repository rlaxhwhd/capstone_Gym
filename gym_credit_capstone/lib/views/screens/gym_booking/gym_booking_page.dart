import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/view_models/gym_booking_view_model.dart';
import 'package:gym_credit_capstone/data/repositories/gym_info_repository.dart';
import '../../screens/gym_booking/payment_page.dart';
import 'package:gym_credit_capstone/views/common_widgets/custom_back_button.dart';

class GymBookingPage extends StatefulWidget {
  final String gymId;
  final List<String> selectedSports;

  const GymBookingPage({super.key, required this.gymId, required this.selectedSports});

  @override
  State<GymBookingPage> createState() => _GymBookingPageState();
}

class _GymBookingPageState extends State<GymBookingPage> {
  final GymInfoRepository _model = GymInfoRepository();
  GymBookingViewModel viewModel = GymBookingViewModel();
  Map<String, int> reservationCounts = {}; // 🔹 특정 날짜의 예약 데이터를 저장
  String gymAbbreviation = "UnknownGym"; // 🔹 체육관 약자 저장
  String formattedDate = "0000-00-00";
  bool isCheckingReservation = false; // 🔹 예약 확인 중일 때 시간 선택 버튼 비활성화
  Map<String, List<String>> disabledTimes = {}; // 🔹 날짜별 비활성화된 시간 저장

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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

      viewModel.generateWeekDates();

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
    List<String> allowedTimes = viewModel.generateAvailableTimes(startTime, endTime);

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
    viewModel = Provider.of<GymBookingViewModel>(context, listen: false);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 현재 날짜 가져오기
    DateTime today = DateTime.now();

    int todayIndex = 0;

    // 오늘 요일을 기준으로 순서 변경
    List<String> reorderedWeekDays = [];

    // 오늘 날짜를 기준으로 순서 변경
    List<DateTime> reorderedWeekDates = [];

    if(viewModel.weekDates.isNotEmpty) {
      todayIndex = viewModel.weekDates.indexWhere((date) => date.day == today.day);

      // 오늘 요일을 기준으로 순서 변경
      reorderedWeekDays = [
        ...viewModel.weekDays.sublist(todayIndex),
        ...viewModel.weekDays.sublist(0, todayIndex)
      ];

      // 오늘 날짜를 기준으로 순서 변경
      reorderedWeekDates = [
        ...viewModel.weekDates.sublist(todayIndex),
        ...viewModel.weekDates.sublist(0, todayIndex)
      ];
    }

    return Consumer<GymBookingViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Card(
                  shadowColor: Colors.white.withAlpha(0),
                  color: Colors.white,
                  child: SizedBox(width: screenWidth, height: screenHeight)
                ),
                Positioned(
                  top: 50,
                  left: screenWidth * 0.07,
                  child: CustomBackButton(),
                ),
                Card(
                  color: Colors.white,
                  shadowColor: Colors.white.withAlpha(0),
                  shape: Border.all(style: BorderStyle.none),
                  margin: EdgeInsets.only(top: 120),
                  child: SizedBox(
                    width: screenWidth,
                    height: screenHeight,
                    child: Card(
                      color: Colors.white,
                      shadowColor: Colors.white.withAlpha(0),
                      shape: Border.all(style: BorderStyle.none),
                      margin: EdgeInsets.only(left: screenWidth * 0.1, right: screenWidth * 0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('날짜 선택', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 18),

                          // 현재 월 표시
                          Text(
                            '${DateTime.now().month}월',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),

                          Divider(color: Colors.black.withAlpha(40), thickness: 1),
                          const SizedBox(height: 8),

                          // 요일 표시
                          Row(
                            children: List.generate(reorderedWeekDays.length, (index) {
                              return Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Center(
                                    child: Text(
                                      reorderedWeekDays[index],
                                      style: TextStyle(
                                        color: 0 == index ? Colors.lightBlueAccent : Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),

                          // 날짜 선택 기능
                          Row(
                            children: List.generate(reorderedWeekDates.length, (index) {
                              int day = reorderedWeekDates[index].day;
                              DateTime selectedDate = reorderedWeekDates[index];

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6), // 🔥 좌우 간격을 넓힘
                                  child: InkWell(
                                    onTap: () {
                                      viewModel.selectDay(index, day);
                                      viewModel.updateSelectedDate(selectedDate); // ✅ 날짜를 올바르게 업데이트
                                      print("[DEBUG] 선택된 날짜: $selectedDate");
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: viewModel.selectedDay == day ? Colors.lightBlueAccent : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(color: Colors.grey.withAlpha(30), spreadRadius: 3, blurRadius: 5),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$day',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: viewModel.selectedDay == day ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),

                          //오늘 표시
                          Row(
                            children: List.generate(7, (index) {
                              int adjustedIndex = (index == 0) ? viewModel.todayIndex : (index <= viewModel.todayIndex ? index - 1 : index);
                              return Expanded(
                                child: Column(
                                  children: [
                                    if (adjustedIndex == viewModel.todayIndex)
                                      const Text(
                                        '오늘',
                                        style: TextStyle(fontSize: 16, color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),

                          Divider(color: Colors.black.withAlpha(40), thickness: 1),
                          const SizedBox(height: 8),

                          const Text('시간 선택', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Stack(
                              children: [
                                Stack(
                                  children: [
                                    Card(
                                      margin: EdgeInsets.only(top:4),
                                      color: Colors.white,
                                      child: SizedBox(
                                        height: 10,
                                        width: 20,
                                      ),
                                    ),
                                    Card(
                                      color: Colors.white.withAlpha(0),
                                      shadowColor: Colors.white.withAlpha(0),
                                      margin: EdgeInsets.only(left: 30),
                                      child: Text ("선택 가능"),
                                    ),
                                  ]
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 110),
                                  child: Stack(
                                    children: [
                                      Card(
                                        margin: EdgeInsets.only(top:4),
                                        color: Colors.white70,
                                        child: SizedBox(
                                          height: 10,
                                          width: 20,
                                        ),
                                      ),
                                      Card(
                                        color: Colors.white.withAlpha(0),
                                        shadowColor: Colors.white.withAlpha(0),
                                        margin: EdgeInsets.only(left: 30),
                                        child: Text ("선택 불가"),
                                      ),
                                    ]
                                  ),
                                )
                              ]
                            ),
                          ),
                          Wrap(
                            spacing: 14,
                            runSpacing: 10,
                            children: viewModel.availableTimes.map((time) {
                              bool isSelected = viewModel.selectedTime == time;
                              DateTime nowKST = DateTime.now().toUtc().add(Duration(hours: 9));
                              DateTime selectedDate = viewModel.selectedDate ?? nowKST;
                              print("[DEBUG FROM BOOKING PAGE] selectedDate: ${viewModel.selectedDate}");
                              print("[DEBUG FROM BOOKING PAGE] selectedDate: ${selectedDate}");
                              DateTime timeSlot = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
                                  int.parse(time.split(":")[0]), int.parse(time.split(":")[1]));
                              print("[DEBUG FROM BOOKING PAGE] timeSlot: ${timeSlot}");
                              bool isPastTime = timeSlot.isBefore(nowKST);
                              print("[DEBUG FROM BOOKING PAGE] isPastTime: ${isPastTime}");
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
                                  backgroundColor: isSelected ? Colors.lightBlueAccent : Colors.white,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Colors.white10, width: 1),
                                  ),
                                  fixedSize: Size(screenWidth * 0.2634259 - 8, 25)
                                ),
                                child: Text(time, style: TextStyle(color: isSelected ? Colors.white : Colors.black),),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 40),

                          Center(
                            child: ElevatedButton(
                              onPressed: viewModel.selectedDate != null ? () {
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
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlueAccent, // 버튼 배경색
                                foregroundColor: Colors.white, // 버튼 글자색
                                padding: EdgeInsets.symmetric(vertical: 18, horizontal: screenWidth * 0.3279), // 내부 여백 조정
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(45.0), // 버튼의 모서리를 둥글게 설정
                                  side: BorderSide(color: Colors.white10, width: 1), // 테두리 설정
                                ),
                              ),
                              child: const Text("결제하기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    )
                  )
                )
              ],
            )
          ),
        );
      },
    );
  }
}
