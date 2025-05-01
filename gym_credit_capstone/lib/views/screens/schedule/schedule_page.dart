import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 사용
import 'package:firebase_auth/firebase_auth.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int reservationCount = 0;

  int selectedDay = 0, bookedDay = 0;
  List<DateTime> weekDates = []; // 현재 날짜를 포함한 1주일 저장 리스트
  int selectedDayIndex = -1; // 선택된 날짜의 인덱스
  int todayIndex = DateTime.now().weekday % 7; // 오늘 날짜의 요일 인덱스 (0: 일, 1: 월, ...)
  final List<String> weekDays = ['일', '월', '화', '수', '목', '금', '토']; // 요일 리스트
  List<Map<String, dynamic>> reservations = [];

  List<String> bookedDate = [];

  List<String> docNamesOfTheDay = [];

  Color cancleTextColor = Colors.lightBlueAccent;

  void initState() {
    super.initState();
    selectedDay = 0;
    generateWeekDays(); // 1주일 날짜를 생성
  }

  void generateWeekDays() {
    int weekdayOffset = DateTime.now().weekday % 7; // 시작 요일을 일요일로 조정
    DateTime sundayStartDate = DateTime.now().subtract(Duration(days: weekdayOffset)); // 일요일 기준 날짜 계산

    weekDates = List.generate(7, (index) => sundayStartDate.add(Duration(days: index))); // 일~토 날짜 생성
  }

  Future<bool> checkReservations() async { // userId를 매개변수로 받음
    print('[checkReservations()] Selected Day: $selectedDay');

    try {
      // Firestore에서 'reservations' 컬렉션 가져오기
      final QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('reservations').get();

      reservationCount = snapshot.docs.length; // 예약된 문서 개수 업데이트
      bookedDate = List.filled(7, ''); // bookedDate를 7개의 빈 문자열로 초기화

      final DateTime currentDay = DateTime.now(); // 오늘 날짜
      final DateTime today = DateTime(currentDay.year, currentDay.month, currentDay.day); // 시간 제거

      reservations = [];
      docNamesOfTheDay = [];

      // 예약 데이터 처리
      for (var doc in snapshot.docs) {
        print("Checking doc | ${doc.id}");

        // doc.id의 마지막 부분 추출
        final List<String> idParts = doc.id.split('_'); // id를 '-' 기준으로 분리
        final String docUserId = idParts.last; // 마지막 부분이 사용자 ID로 가정

        // 사용자의 ID와 비교
        if (docUserId == FirebaseAuth.instance.currentUser!.uid) {
          final String gymId = doc.get('gymId'); // Firestore 필드 'gymId'
          final String time = doc.get('time');   // Firestore 필드 'time'
          final String dateString = doc.get('date'); // Firestore 필드 'date'
          final List<String> dateParts = dateString.split('-'); // 날짜 분리
          final int docMonth = int.parse(dateParts[1]);
          final int docDay = int.parse(dateParts[2]);

          final DateTime docDate = DateTime(today.year, docMonth, docDay);
          final int relativeIndex = docDate.difference(today).inDays;

          // 예약 날짜가 7일 범위 내에 있는 경우만 처리
          if (relativeIndex >= 0 && relativeIndex < 7) {
            if (!bookedDate.contains('${docMonth}-${docDay}')) {
              bookedDate[relativeIndex] = '${docMonth}-${docDay}'; // 날짜 저장

              // 날짜를 '0월 00일 ㅁ요일' 형식으로 변환
              final String formattedDate =
                  '${docMonth}월 ${docDay}일 ${_getWeekdayString(weekDates[relativeIndex].weekday)}';

              // 예약 정보를 리스트에 추가
              reservations.add({
                'gymId': gymId,
                'time': time,
                'date': formattedDate, // 변환된 날짜 형식
              });

              fetchStatus(gymId, time, false);

              docNamesOfTheDay.add(doc.id);
            }
          }
        }
      }

      print("[DEBUG] Booked Dates: $docNamesOfTheDay");
      print("[DEBUG] Booked Dates: $bookedDate");
      print("[DEBUG] Reservations: $reservations");

      // 선택한 날짜와 예약된 날짜를 비교
      if (selectedDay > 0 &&
          selectedDayIndex >= 0 &&
          selectedDayIndex < bookedDate.length &&
          bookedDate[selectedDayIndex].isNotEmpty &&
          selectedDay == int.parse(bookedDate[selectedDayIndex].split('-')[1])) {
        print("The day has a reservation.");
        return true; // 예약된 일정이 있는 경우 true 반환
      }
    } catch (e) {
      print("Error fetching reservations: $e");
    }

    print("The day doesn't have a reservation.");
    return false; // 예약된 일정이 없는 경우 false 반환
  }

  // 요일을 문자열로 변환하는 함수
  String _getWeekdayString(int weekday) {
    switch (weekday) {
      case 1:
        return '월요일';
      case 2:
        return '화요일';
      case 3:
        return '수요일';
      case 4:
        return '목요일';
      case 5:
        return '금요일';
      case 6:
        return '토요일';
      case 7:
        return '일요일';
      default:
        return '';
    }
  }

  //찾을 예약 문서명 만들기
  Future<String> createDocName(String gymId, String time) async {
    final QuerySnapshot gymSnapshot =
    await FirebaseFirestore.instance.collection('Gym_list').get();
    final QuerySnapshot resSnapshot =
    await FirebaseFirestore.instance.collection('reservations').get();

    String gymInitial = '';
    String sportInitial = '';
    String userId = FirebaseAuth.instance.currentUser!.uid;

    String date = '';

    for(int i = 0; i < gymSnapshot.docs.length; i++) {
      if(gymSnapshot.docs.asMap()[i]!.id == gymId) {
        gymInitial = gymSnapshot.docs.asMap()[i]!.get('약자');
        break;
      }
    }

    print("[DEBUG] ${gymInitial}");

    String earlyId = time + '_' + gymInitial + '_';

    for(int i = 0; i < resSnapshot.docs.length; i++) {
      List<String> splittedId = resSnapshot.docs.asMap()[i]!.id.split('_');
      String comparableId = splittedId[1] + '_' + splittedId[2] + '_' + userId;

      if(comparableId == earlyId + userId) {
        date = resSnapshot.docs.asMap()[i]!.get('date');
        break;
      }
    }

    print("[DEBUG] ${date}");

    String defaultId = date + '_' + time + '_' + gymInitial + '_';

    for(int i = 0; i < resSnapshot.docs.length; i++) {
      List<String> splittedId = resSnapshot.docs.asMap()[i]!.id.split('_');
      String comparableId = splittedId[0] + '_' + splittedId[1] + '_' + splittedId[2] + '_' + userId;

      if(comparableId == defaultId + userId) {
        sportInitial = resSnapshot.docs.asMap()[i]!.get('sports')['sportName'];
        break;
      }
    }

    print("[DEBUG] ${defaultId}");

    String targetResId = defaultId + sportInitial + '_' + userId;

    print("[DEBUG] ${targetResId}");

    return targetResId;
  }

  // Firestore 문서의 status를 false로 설정하는 함수
  void cancelReservation(String gymId, String time) async {
    try {
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(await createDocName(gymId, time))
          .update({'status': false});
      print('Reservation cancelled successfully.');
      fetchStatus(gymId, time, true);
    } catch (e) {
      print('Error cancelling reservation: $e');
    }
  }

  // 예약 취소 확인 창을 띄우는 함수
  void showConfirmationDialog(BuildContext context, String gymId, String time, String date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('예약 취소'),
          content: Text('정말로 예약을 취소하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 확인 창 닫기
              },
              child: Text('아니오'),
            ),
            TextButton(
              onPressed: () {
                cancelReservation(gymId, time); // 예약 취소 실행
                Navigator.of(context).pop(); // 확인 창 닫기
              },
              child: Text('예'),
            ),
          ],
        );
      },
    );
  }

  void fetchStatus(String gymId, String time, bool isWorkingByButtonPressing) async {
    String cancellationStatusMessage = '취소 중 문제가 발생하였습니다.';

    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .doc(await createDocName(gymId, time))
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        bool status = data['status'] ?? false;

        if((status == false && cancleTextColor == Colors.red) || (status == true && cancleTextColor == Colors.grey)) {
          setState(() {
            cancellationStatusMessage = "취소가 성공적으로 완료되었습니다.";
            print('[CANCLE BUTTON DEBUG] Color Changed Succesfully');
            cancleTextColor = status ? Colors.red : Colors.grey;
          });
        }
      }
    } catch (e) {
      print('Error fetching document: $e');
    }

    print('[CANCLE BUTTON DEBUG] The cancellation proceeded by button status is \'${isWorkingByButtonPressing}\'');

    if(isWorkingByButtonPressing) {
      final snackBar = SnackBar(
        content: Text(cancellationStatusMessage),
        duration: Duration(seconds: 2), // 표시 시간 설정
        action: SnackBarAction(
          label: '닫기',
          onPressed: () {
            // 닫기 버튼을 눌렀을 때 실행될 동작
          },
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white; // 아래 배경 색상 정의

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(right: 16, left: 16),
        color: backgroundColor, // 전체 배경 색상
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              const Text(
                '예약 일정',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),

              Text(
                '${DateTime.now().month}월', // 현재 월을 가져와 표시
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),

              Divider(
                color: Colors.black.withAlpha(40),      // 라인의 색상
                thickness: 1,            // 라인의 두께
              ),
              SizedBox(height: 8),

              // 추가된 Row 코드
              // 요일 표시 Row (선택 불가능)
              Row(
                children: List.generate(weekDays.length, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 6, right: 6),
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          weekDays[index], // 요일 텍스트
                          style: TextStyle(
                            color: (todayIndex == index) ? Colors.lightBlueAccent : Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),

              // 날짜 표시 Row (선택 가능)
              Row(
                children: weekDates.map((date) {
                  int day = date.day; // 날짜의 일(day)을 가져옴
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedDay = day; // 선택된 날짜 업데이트
                          selectedDayIndex = weekDates.indexOf(date); // 선택된 날짜의 인덱스 업데이트
                        });
                        print('버튼 클릭됨');
                        print('selectedDayIndex: $selectedDayIndex'); // 선택된 날짜 인덱스 출력
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 6, right: 6),
                        padding: EdgeInsets.only(top: 6, bottom: 6),
                        decoration: BoxDecoration(
                          color: (selectedDay == day) ? Colors.lightBlueAccent : Colors.white, // 배경색 설정
                          borderRadius: BorderRadius.circular(10), // BorderRadius 추가
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(30),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$day', // 날짜 표시
                            style: TextStyle(
                              fontSize: 18,
                              color: (selectedDay == day) ? Colors.white : Colors.black, // 선택된 날짜의 텍스트 색상
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12),

              // 추가된 Row 코드
              Row(
                children: List.generate(7, (index) {
                  return Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 8), // 간격 추가
                        (todayIndex == index) // 오늘 위치에서만 "오늘" 텍스트 표시
                            ? const Text(
                          '오늘',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            : const Text(''), // 다른 위치에는 빈 텍스트 표시
                      ],
                    ),
                  );
                }),
              ),
              SizedBox(height: 12),

              Divider(
                color: Colors.black.withAlpha(40),      // 라인의 색상
                thickness: 1,            // 라인의 두께
              ),
              SizedBox(height: 8),

              const Text(
                '예약 시간',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 0),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 20), // 좌우 여백 추가
                width: 400, // 컨테이너 가로 크기
                height: 440, // 컨테이너 세로 크기
                color: Colors.white, // 배경 색상
                child: (selectedDay <= 0)
                    ? Center(
                  child: Text(
                    '날짜를 선택해 주세요', // 텍스트 표시
                    style: TextStyle(fontSize: 22, color: Colors.grey),
                  ),
                )
                    : FutureBuilder<bool>(
                  future: checkReservations(), // 예약 여부 확인
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(), // 로딩 표시
                      );
                    } else if (snapshot.hasData && !snapshot.data!) {
                      return Center(
                        child: Text(
                          '예약된 일정이 없습니다', // 텍스트 표시
                          style: TextStyle(fontSize: 22, color: Colors.grey),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data!) {
                      return Align(
                        alignment: Alignment.topCenter, // 부모 객체의 최상단 중앙 정렬
                        child: Container(
                          width: 500, // 컨테이너 가로 크기
                          decoration: BoxDecoration(
                            color: Colors.white, // 컨테이너 배경 색상
                            borderRadius: BorderRadius.circular(10), // 둥근 테두리
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0), // 컨테이너 내부 여백
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: reservations
                                    .where((reservation) {
                                      // 예약된 날짜
                                      final String reservationDate = reservation['date'];

                                      // 선택된 날짜(DateTime -> '0월 00일 0요일' 형식으로 변환)
                                      final DateTime selectedWeekDate = weekDates[selectedDayIndex];
                                      final String formattedDate = '${selectedWeekDate.month}월 ${selectedWeekDate.day}일 ${_getWeekdayString(selectedWeekDate.weekday)}';

                                      // 두 값을 비교
                                      return reservationDate == formattedDate;
                                    }) // Filter by selected date
                                    .map((reservation) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8, bottom: 8), // 세트 간 간격 추가
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white, // 배경 색상
                                        borderRadius: BorderRadius.circular(10), // 둥근 테두리
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withAlpha(40), // 그림자 색상과 투명도
                                            spreadRadius: 2, // 그림자 퍼짐 정도
                                            blurRadius: 5, // 그림자 흐림 정도
                                            offset: Offset(0, 5), // 그림자의 위치 (x, y)
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 6, left: 16, top: 8, bottom: 8), // 세트 내부 여백
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    reservation['date'], // 날짜
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    reservation['gymId'], // 예약 제목
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    reservation['time'] + '~' +
                                                        (int.parse(reservation['time'].split(':')[0]) + 1).toString() +
                                                        ':00', // 시간
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // 세로 실선
                                            Container(
                                              width: 1,
                                              height: 50,
                                              margin: EdgeInsets.symmetric(horizontal: 0),
                                              color: Colors.grey.withAlpha(50),
                                            ),
                                            // 버튼 영역
                                            ElevatedButton(
                                              onPressed: () {
                                                if (reservation != null && reservation.containsKey('gymId')) {
                                                  // 예약 ID를 가져옴
                                                  String gymId = reservation['gymId'];

                                                  // 확인 창 호출
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text('예약 취소'),
                                                        content: Text('정말로 ${gymId}의 예약을 취소하시겠습니까?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop(); // 확인 창 닫기
                                                            },
                                                            child: Text('아니오'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              cancelReservation(reservation['gymId'],
                                                                reservation['time']
                                                              ); // 예약 취소 실행
                                                              Navigator.of(context).pop(); // 확인 창 닫기
                                                            },
                                                            child: Text('예'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  print('예약 데이터가 올바르지 않습니다.');
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: Text(
                                                '취소',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: cancleTextColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          '예약 정보를 불러오지 못했습니다', // 에러 메시지
                          style: TextStyle(fontSize: 22, color: Colors.red),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}