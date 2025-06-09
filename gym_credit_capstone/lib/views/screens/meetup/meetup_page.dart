// views/screens/meetup/meetup_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/view_models/meetup_view_model.dart';
import 'package:gym_credit_capstone/views/screens/meetup/meetup_create_page.dart';

class MeetupPage extends StatefulWidget {
  const MeetupPage({Key? key}) : super(key: key);

  @override
  State<MeetupPage> createState() => _MeetupPageState();
}

class _MeetupPageState extends State<MeetupPage> {
  late DateTime selectedDate;
  late List<DateTime> weekDates;
  late int todayIndex;

  @override
  void initState() {
    super.initState();
    // 초기 선택 날짜는 오늘
    selectedDate = DateTime.now();

    // 이번 주(일요일 시작) 7일치 날짜 계산
    final now = DateTime.now();
    todayIndex = now.weekday % 7;
    final sunday = now.subtract(Duration(days: todayIndex));
    weekDates = List.generate(7, (i) => sunday.add(Duration(days: i)));

    // 모임 데이터 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetupViewModel>().fetchAllMeetups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeetupViewModel>();
    final allMeetups = vm.meetups;

    // 선택된 날짜의 모임만 필터
    final todaysMeetups = allMeetups.where((m) =>
    m.meetupTime.year == selectedDate.year &&
        m.meetupTime.month == selectedDate.month &&
        m.meetupTime.day == selectedDate.day
    ).toList();

    const weekDayLabels = ['일','월','화','수','목','금','토'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 타이틀
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Text(
                  "스포츠 모임",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // 서브 타이틀 + 검색
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    "모임 일정 캘린더",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 월 표시
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "${selectedDate.month}월",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),

            Divider(color: Colors.black.withAlpha(40), thickness: 1),

            // 요일 행
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: List.generate(7, (i) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        weekDayLabels[i],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 4),

            // 날짜 행 (오직 selectedDate 만 파란색)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: List.generate(7, (i) {
                  final date = weekDates[i];
                  final isSelected = date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF69B7FF) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withAlpha(30),
                                spreadRadius: 2,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 4),

            Divider(color: Colors.black.withAlpha(40), thickness: 1),

            // 모임 목록 또는 안내 문구
            Expanded(
              child: vm.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : todaysMeetups.isEmpty
                  ? Center(
                child: Text(
                  "선택된 날짜에 등록된 모임이 없습니다.\n+ 버튼을 눌러 모임을 등록하세요.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: todaysMeetups.length,
                itemBuilder: (_, idx) {
                  final m = todaysMeetups[idx];
                  final timeStr =
                      "${m.meetupTime.hour.toString().padLeft(2, '0')}:${m.meetupTime.minute.toString().padLeft(2, '0')}";
                  return ListTile(
                    leading: Icon(Icons.group),
                    title: Text(m.title),
                    subtitle: Text("${m.gymName} / ${m.capacity}명"),
                    trailing: Text(timeStr),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MeetupCreatePage()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
