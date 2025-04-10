import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GymBookingPage extends StatefulWidget {
  final String gymId;

  const GymBookingPage({super.key, required this.gymId});

  @override
  _GymBookingPageState createState() => _GymBookingPageState();
}

class _GymBookingPageState extends State<GymBookingPage> {
  DateTime selectedDate = DateTime.now(); // 기본값: 오늘 날짜
  String selectedTime = ""; // 선택된 시간 저장
  List<String> availableTimes = []; // 예약 가능한 시간 목록
  String userId = FirebaseAuth.instance.currentUser?.uid ?? ""; // 현재 로그인된 사용자 ID

  @override
  void initState() {
    super.initState();
    fetchAvailableTimes();
  }

  Future<void> fetchAvailableTimes() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot doc =
    await firestore.collection('Gym_list').doc(widget.gymId).get();

    if (doc.exists) {
      String operatingHours = doc['운영시간']; // '08:00~20:00' 형식
      setState(() {
        availableTimes = generateAvailableTimeSlots(operatingHours);
      });
    } else {
      setState(() {
        availableTimes = []; // 운영 시간이 없을 경우 빈 목록 반환
      });
    }
  }

  List<String> generateAvailableTimeSlots(String operatingHours) {
    final times = operatingHours.split('~');
    final startTime = int.parse(times[0].split(':')[0]); // 시작 시간
    final endTime = int.parse(times[1].split(':')[0]); // 종료 시간

    List<String> timeSlots = [];
    for (int i = startTime; i <= endTime; i++) {
      String time = i.toString().padLeft(2, '0') + ':00';
      if (time != '12:00') { // 12:00은 제외
        timeSlots.add(time);
      }
    }
    return timeSlots;
  }

  Future<void> saveReservationToFirestore() async {
    try {
      // 현재 시간 가져오기
      final currentTime = DateTime.now();

      // AM/PM 대신 정확히 24시간 형식으로 변환
      final nowInUTCPlus9 = DateTime.now().toUtc().add(Duration(hours: 9));
      final formattedCreateTime = DateFormat('yyyy년 M월 d일 HH시 mm분 ss초').format(nowInUTCPlus9) + " UTC+9";
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      // Firestore에 저장할 데이터 생성
      CollectionReference reservations = FirebaseFirestore.instance.collection('reservations');
      await reservations.add({
        'createtime': formattedCreateTime, // 현재 시간을 포맷하여 저장
        'date': formattedDate, // 선택된 날짜 포맷 저장
        'gymid': widget.gymId,
        'sports': {'sportname': 1500},
        'status': true,
        'time': selectedTime, // 선택된 시간 저장
        'userid': userId, // 현재 로그인된 사용자 ID 저장
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("예약이 완료되었습니다!")),
      );
    } catch (e) {
      print("오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("예약에 실패했습니다!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();

    // 오늘부터 6일 뒤까지의 날짜만 필터링
    List<DateTime> availableDates = List.generate(
      7,
          (index) => today.add(Duration(days: index)),
    );

    return Scaffold(
      appBar: AppBar(title: Text("${widget.gymId} 예약 페이지")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "예약 가능한 날짜를 선택하세요:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                "${today.year}년 ${today.month}월",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: availableDates.map((date) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedDate = date; // 선택된 날짜 저장
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "선택된 날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                        ),
                      );
                    },
                    child: Text(DateFormat('d일').format(date)), // 일(day)만 표시
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text(
                "예약 가능한 시간을 선택하세요:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: availableTimes.map((time) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedTime = time; // 선택된 시간 저장
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("선택된 시간: $selectedTime")),
                      );
                    },
                    child: Text(time),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: selectedDate != null && selectedTime.isNotEmpty
                      ? saveReservationToFirestore
                      : null,
                  child: Text("예약하기"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}