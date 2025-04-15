// views/screens/meetup/meetup_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/view_models/meetup_view_model.dart';
import 'package:gym_credit_capstone/views/screens/meetup/meetup_create_page.dart';

class MeetupPage extends StatelessWidget {
  const MeetupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final meetupViewModel = context.watch<MeetupViewModel>();

    // 오늘부터 7일치 날짜 생성
    final List<DateTime> days = List.generate(
      7,
          (index) => DateTime.now().add(Duration(days: index)),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) 맨 위 "스포츠 모임" (가운데 정렬)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  "스포츠 모임",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            // 2) "모임 일정 캘린더" 왼쪽 정렬 + 검색 아이콘(오른쪽)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text(
                    "모임 일정 캘린더",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // TODO: 검색 로직을 여기에 추가하거나, 검색 화면으로 이동
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // 3) 가로 스크롤 캘린더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final formattedDate = "${day.month}/${day.day}";
                    final isToday = day.year == DateTime.now().year &&
                        day.month == DateTime.now().month &&
                        day.day == DateTime.now().day;

                    // 요일 얻기 (일 ~ 토)
                    final weekdayLabel = ["일", "월", "화", "수", "목", "금", "토"][day.weekday % 7];

                    return Container(
                      width: 50,
                      margin: const EdgeInsets.only(right: 8.0),
                      decoration: BoxDecoration(
                        color: isToday ? const Color(0xFF69B7FF) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 오늘이면 "오늘" 표시, 아니면 weekdayLabel
                          Text(
                            isToday ? "오늘" : weekdayLabel,
                            style: TextStyle(
                              color: isToday ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: isToday ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // (생략) 모임 목록 영역
            Expanded(
              child: Center(
                child: Text(
                  "등록된 모임이 없습니다.\n+ 버튼을 눌러 모임을 등록하세요.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // 우측 하단 + 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MeetupCreatePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
