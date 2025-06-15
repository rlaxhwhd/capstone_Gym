import 'package:flutter/material.dart';

class PickDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final void Function(DateTime) onConfirm;

  const PickDatePicker({
    super.key,
    this.initialDate,
    required this.onConfirm,
  });

  @override
  State<PickDatePicker> createState() => _PickDatePickerState();
}

class _PickDatePickerState extends State<PickDatePicker> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedMonth = widget.initialDate ?? DateTime.now();
    _selectedDate = widget.initialDate;
  }

  void _goToPrevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final days = List.generate(lastDay.day, (i) => i + 1);
    final blanks = List.generate(startWeekday, (_) => null);
    final calendarDays = [...blanks, ...days];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: _goToPrevMonth, icon: const Icon(Icons.chevron_left)),
              Text('$year년 $month월',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(onPressed: _goToNextMonth, icon: const Icon(Icons.chevron_right)),
            ],
          ),
          const SizedBox(height: 12),

          // 요일 표시
          Row(
            children: ['일', '월', '화', '수', '목', '금', '토'].map((d) {
              return Expanded(
                  child: Center(
                      child: Text(d,
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))));
            }).toList(),
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: calendarDays.map((day) {
              if (day == null) return const SizedBox();
              final date = DateTime(year, month, day);
              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xffE1F0FF) : null,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text('$day'),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // 버튼
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff69B7FF),
                    side: const BorderSide(color: Color(0xff69B7FF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedDate != null) {
                      widget.onConfirm(_selectedDate!);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff69B7FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('확인', style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
