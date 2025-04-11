import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/view_models/gym_booking_view_model.dart';

class GymBookingPage extends StatefulWidget {
  final String gymId;
  final List<String> selectedSports;

  const GymBookingPage({super.key, required this.gymId, required this.selectedSports});

  @override
  State<GymBookingPage> createState() => _GymBookingPageState();
}

class _GymBookingPageState extends State<GymBookingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<GymBookingViewModel>(context, listen: false);
      viewModel.fetchAvailableTimes(widget.gymId);
      viewModel.calculateSportsSummary(widget.gymId, widget.selectedSports);
    });
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
                  Text(
                    "예약 가능한 날짜를 선택하세요:",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(7, (index) {
                      DateTime date = DateTime.now().add(Duration(days: index));
                      return ElevatedButton(
                        onPressed: () {
                          viewModel.updateSelectedDate(date);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("선택된 날짜: ${date.toLocal()}")),
                          );
                        },
                        child: Text("${date.day}일"),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "예약 가능한 시간을 선택하세요:",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: viewModel.availableTimes.isNotEmpty
                        ? viewModel.availableTimes.map((time) {
                      return ElevatedButton(
                        onPressed: () {
                          viewModel.updateSelectedTime(time);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("선택된 시간: $time")),
                          );
                        },
                        child: Text(time),
                      );
                    }).toList()
                        : [
                      Text("예약 가능한 시간이 없습니다."),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: (viewModel.selectedDate != null && viewModel.selectedTime.isNotEmpty)
                          ? () async {
                        await viewModel.saveReservation(widget.gymId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("예약이 완료되었습니다!")),
                        );
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