import 'package:flutter/material.dart';
//import 'package:gym_credit_capstone/data/models/home_events_card_model.dart';

class GymInfoPage extends StatelessWidget {
  final String roadName, gymName, openTime;

  const GymInfoPage({required this.roadName, required this.openTime, required this.gymName});

  @override
  Widget build(BuildContext context) {
    // 화면 크기 가져오기
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('Gym Info')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gymName,
              style: TextStyle(
                color: const Color(0xFF191919),
                fontSize: screenWidth * 0.06,  // 반응형 글자 크기
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),  // 반응형 여백
            Text(
              '예약 정보',
              style: TextStyle(
                color: const Color(0xFF69B7FF),
                fontSize: screenWidth * 0.04,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              '서비스 대상',
              style: TextStyle(
                color: const Color(0xFF191919),
                fontSize: screenWidth * 0.04,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              '서비스 일자',
              style: TextStyle(
                color: const Color(0xFF191919),
                fontSize: screenWidth * 0.04,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              '예약 가능 일자',
              style: TextStyle(
                color: const Color(0xFF191919),
                fontSize: screenWidth * 0.04,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              '시설 사용 시간',
              style: TextStyle(
                color: const Color(0xFF191919),
                fontSize: screenWidth * 0.04,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              '취소 가능 기준',
              style: TextStyle(
                color: const Color(0xFF191919),
                fontSize: screenWidth * 0.04,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "도로명: " + roadName,//gymInfo['도로명'].toString(),
              style: TextStyle(
                color: const Color(0xFF4B4D4F),
                fontSize: screenWidth * 0.04,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              '현위치로부터 6.2km',
              style: TextStyle(
                color: const Color(0xFF4B4D4F),
                fontSize: screenWidth * 0.04,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              '성인(등록된 팀), 청소년(등록된 팀)',
              style: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.04,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "날짜 및 시간: " + "DATE_VALUE_REQUIRED" + ' ' + openTime,//gymInfo['운영시간'].toString(),
              style: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.04,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,  // 버튼 색상
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.1,  // 버튼 너비
                  vertical: screenHeight * 0.02,  // 버튼 높이
                ),
              ),
              child: Text(
                '예약하기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
