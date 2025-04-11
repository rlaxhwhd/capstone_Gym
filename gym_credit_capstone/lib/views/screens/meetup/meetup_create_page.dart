// File: views/screens/meetup/meetup_create_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/view_models/meetup_view_model.dart';

class MeetupCreatePage extends StatefulWidget {
  const MeetupCreatePage({Key? key}) : super(key: key);

  @override
  State<MeetupCreatePage> createState() => _MeetupCreatePageState();
}

class _MeetupCreatePageState extends State<MeetupCreatePage> {
  final _gymNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _capacityController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _gymNameController.dispose();
    _titleController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    // 날짜 선택 (DatePicker)
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // 오늘부터 선택
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      // 시간 선택 (TimePicker)
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final selected = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          _selectedDateTime = selected;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("모임 등록"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 체육관명 입력
            TextField(
              controller: _gymNameController,
              decoration: const InputDecoration(
                labelText: "체육관명",
                hintText: "예) 광명체육관",
              ),
            ),
            const SizedBox(height: 16),
            // 모임 제목(설명) 입력
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "모임 제목",
                hintText: "모임에 대해 간단히 설명해주세요",
              ),
            ),
            const SizedBox(height: 16),
            // 모임 인원 입력
            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "모임 인원",
                hintText: "최대 인원을 입력해주세요",
              ),
            ),
            const SizedBox(height: 16),
            // 날짜 및 시간 선택
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime != null
                        ? "선택된 시간: ${_selectedDateTime!.toLocal().toString().substring(0, 16)}"
                        : "날짜와 시간을 선택하세요",
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickDateTime,
                  child: const Text("선택"),
                ),
              ],
            ),
            const Spacer(),
            // 등록 버튼
            ElevatedButton(
              onPressed: () async {
                if (_gymNameController.text.trim().isEmpty ||
                    _titleController.text.trim().isEmpty ||
                    _capacityController.text.trim().isEmpty ||
                    _selectedDateTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("모든 항목을 입력해주세요.")),
                  );
                  return;
                }
                final capacity = int.tryParse(_capacityController.text.trim());
                if (capacity == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("모임 인원은 숫자로 입력해주세요.")),
                  );
                  return;
                }

                final vm = context.read<MeetupViewModel>();
                await vm.createMeetup(
                  gymName: _gymNameController.text.trim(),
                  title: _titleController.text.trim(),
                  meetupTime: _selectedDateTime!,
                  capacity: capacity,
                );

                Navigator.pop(context); // 등록 후 이전 화면으로 복귀
              },
              child: const Text("등록하기"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
