import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/view_models/schedule_view_model.dart';
import 'package:gym_credit_capstone/data/repositories/auth_repository.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = AuthRepository(); // 🔥 객체 생성
    final String userId =
        authRepository.getCurrentUserId() ??
        ''; // 🔥 Firebase에서 현재 로그인된 사용자 ID 가져오기

    String comparableFormatted = '';

    print("[DEBUG SCHEDULE PAGE] SchedulePage 빌드됨! userId: ${userId}");

    final ScheduleViewModel testViewModel = ScheduleViewModel();
    print(
      "[DEBUG SCHEDULE PAGE] ScheduleViewModel 직접 생성됨! reservations: ${testViewModel.reservations}",
    );

    return ChangeNotifierProvider(
      create: (_) {
        print(
          "[DEBUG SCHEDULE PAGE] ScheduleViewModel 생성됨!",
        ); // ✅ ViewModel 생성 로그
        return ScheduleViewModel()..loadReservations(userId);
      },
      child: Consumer<ScheduleViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '예약 일정',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 현재 월 표시
                    Text(
                      '${DateTime.now().month}월',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Divider(color: Colors.black.withAlpha(40), thickness: 1),
                    const SizedBox(height: 8),

                    // 요일 표시
                    Row(
                      children: List.generate(viewModel.weekDays.length, (
                        index,
                      ) {
                        return Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Center(
                              child: Text(
                                viewModel.weekDays[index],
                                style: TextStyle(
                                  color:
                                      viewModel.todayIndex == index
                                          ? Colors.lightBlueAccent
                                          : Colors.black,
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
                      children: List.generate(viewModel.weekDates.length, (
                        index,
                      ) {
                        int day = viewModel.weekDates[index].day;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            // 🔥 좌우 간격을 넓힘
                            child: InkWell(
                              onTap: () {
                                viewModel.selectDay(index, day);

                                // 🔥 선택된 날짜 확인용 디버깅 로그 추가
                                print(
                                  "선택된 날짜: $day, selectedDayIndex: ${viewModel.selectedDayIndex}",
                                );

                                //예약 정보 불러오기
                                viewModel.loadReservations(userId);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color:
                                      viewModel.selectedDay == day
                                          ? Colors.lightBlueAccent
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withAlpha(30),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '$day',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          viewModel.selectedDay == day
                                              ? Colors.white
                                              : Colors.black,
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

                    // 오늘 표시
                    Row(
                      children: List.generate(7, (index) {
                        return Expanded(
                          child: Column(
                            children: [
                              if (viewModel.todayIndex == index)
                                const Text(
                                  '오늘',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.lightBlueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),

                    Divider(color: Colors.black.withAlpha(40), thickness: 1),
                    const SizedBox(height: 8),

                    const Text(
                      '예약 시간',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // 예약 정보 표시
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      width: 400,
                      height: 440,
                      color: Colors.white,
                      child:
                          viewModel.selectedDay <= 0
                              ? const Center(
                                child: Text(
                                  '날짜를 선택해 주세요',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                              : viewModel.checkScheduleReservations()
                              ? ListView.builder(
                                itemCount:
                                    viewModel.reservations.where((reservation) {
                                      DateTime selectedWeekDate =
                                          viewModel.weekDates[viewModel
                                              .selectedDayIndex];
                                      String selectedYear =
                                          selectedWeekDate.year.toString();
                                      String selectedMonth =
                                          selectedWeekDate.month.toString();
                                      String selectedDate =
                                          selectedWeekDate.day.toString();

                                      // 🔥 요일 제거 후 YYYY-MM-DD 형식 변환
                                      comparableFormatted =
                                          selectedYear +
                                          '-' +
                                          ((selectedMonth.length < 2)
                                              ? '0'
                                              : '') +
                                          selectedMonth +
                                          '-' +
                                          ((selectedDate.length < 2)
                                              ? '0'
                                              : '') +
                                          selectedDate;

                                      print(
                                        '[DEBUG VIEW PAGE] Comparable Formatted => ${comparableFormatted}',
                                      );
                                      print(
                                        '[DEBUG VIEW PAGE] Rservation => ${reservation}',
                                      );
                                      print(
                                        '[DEBUG VIEW PAGE] Rservation => ${reservation.date}',
                                      );
                                      return reservation.date ==
                                          comparableFormatted;
                                    }).length,
                                itemBuilder: (context, index) {
                                  final filteredReservations =
                                      viewModel.reservations.where((
                                        reservation,
                                      ) {
                                        return reservation.date ==
                                            comparableFormatted;
                                      }).toList();

                                  final reservation =
                                      filteredReservations[index];

                                  // 🔥 디버깅용 로그 추가
                                  print(
                                    "[DEBUG VIEW PAGE] 예약된 일정: $reservation",
                                  );

                                  return Card(
                                    color: Colors.white,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: 4,
                                        bottom: 4,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          "${reservation.date}",
                                        ), // 날짜 표시
                                        subtitle: RichText(
                                          text: TextSpan(
                                            style:
                                                DefaultTextStyle.of(
                                                  context,
                                                ).style, // 기본 스타일 유지
                                            children: [
                                              TextSpan(
                                                text: "${reservation.gymId}\n",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              // 🔥 장소
                                              WidgetSpan(
                                                child: SizedBox(height: 20),
                                              ),
                                              // 🔥 간격 추가
                                              TextSpan(
                                                text:
                                                    "${reservation.time}~${int.parse(reservation.time.split(':')[0]) + 1}:00",
                                              ),
                                              // 🔥 시간
                                            ],
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          // 🔥 최소 크기로 설정하여 버튼 정렬 유지
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(right: 6),
                                              width: 2, // 🔥 실선의 너비
                                              height: 50, // 🔥 실선의 높이 (버튼과 맞추기)
                                              color: Colors.grey.withAlpha(
                                                50,
                                              ), // 🔥 실선 색상
                                            ),
                                            const SizedBox(width: 10),
                                            // 🔥 실선과 버튼 사이 간격 조정
                                            ElevatedButton(
                                              onPressed:
                                                  reservation.status
                                                      ? () => viewModel
                                                          .showCancelDialog(
                                                            context,
                                                            reservation.docId,
                                                            reservation.time,
                                                          ) // 🔥 예약 취소 확인 다이얼로그 실행
                                                      : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                shadowColor:
                                                    reservation.status
                                                        ? Colors.transparent
                                                        : Colors.grey,
                                                disabledBackgroundColor:
                                                    Colors.white,
                                              ),
                                              child: Text(
                                                '취소',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color:
                                                      reservation.status
                                                          ? Colors.red
                                                          : Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                              : const Center(
                                child: Text(
                                  '예약된 일정이 없습니다',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
