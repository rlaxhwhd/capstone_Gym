import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SliderWithIndicator extends StatefulWidget {
  const SliderWithIndicator({super.key});

  @override
  _SliderWithIndicatorState createState() => _SliderWithIndicatorState();
}

class _SliderWithIndicatorState extends State<SliderWithIndicator> {
  final List<String> images = [
    'assets/images/events/event1.jpg',
    'assets/images/events/event2.jpg',
    'assets/images/events/event3.jpg',
  ];

  final List<String> links = [
    'https://www.naver.com',
    'https://www.google.com',
    'https://www.daum.net',
  ];

  int _currentIndex = 0; // 현재 페이지 번호 추적

  // URL 열기 함수
  void _launchURL(String url) async {
    Uri uri = Uri.parse(url); // URL을 Uri 객체로 변환
    if (await canLaunchUrl(uri)) { // URL을 열 수 있는지 확인
      await launchUrl(uri, mode: LaunchMode.externalApplication); // URL 열기
    } else {
      // URL을 열 수 없을 경우 오류 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // 화면 너비 가져오기
    double bannerHeight = screenWidth * (221 / 393); // 비율 유지 (XD 기준)

    return Column(
      children: [
        // 배너 슬라이더
        SizedBox(
          height: bannerHeight, // 반응형 높이 적용
          width: screenWidth, // 화면 너비에 맞춤
          child: Stack(
            children: [
              // PageView (이미지 슬라이드)
              PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;  // 페이지가 변경될 때마다 현재 페이지 번호 업데이트
                  });
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // 이미지 클릭 시 해당 링크로 이동
                      _launchURL(links[index]);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image.asset(
                        images[index],
                        fit: BoxFit.cover,
                        width: screenWidth, // 너비 조정
                      ),
                    ),
                  );
                },
              ),
              // 이미지 위에 페이지 번호 표시
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${images.length}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
