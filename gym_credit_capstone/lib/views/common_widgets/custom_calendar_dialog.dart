import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const CustomCalendarDialog({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<CustomCalendarDialog> createState() => _CustomCalendarDialogState();
}

class _CustomCalendarDialogState extends State<CustomCalendarDialog> {
  late DateTime selectedDate;
  late DateTime displayedMonth;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    displayedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  void _previousMonth() {
    setState(() {
      displayedMonth = DateTime(displayedMonth.year, displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + 1);
    });
  }

  List<Widget> _buildDayLabels() {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return days.map((day) => Center(child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)))).toList();
  }

  List<Widget> _buildDateCells() {
    final firstDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final totalDays = firstWeekday + lastDayOfMonth.day;
    final rows = (totalDays / 7).ceil();

    List<Widget> cells = [];
    int day = 1;

    for (int i = 0; i < rows * 7; i++) {
      if (i < firstWeekday || day > lastDayOfMonth.day) {
        cells.add(Container());
      } else {
        final currentDate = DateTime(displayedMonth.year, displayedMonth.month, day);
        final isSelected = currentDate.year == selectedDate.year && currentDate.month == selectedDate.month && currentDate.day == selectedDate.day;

        cells.add(GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = currentDate;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xff69B7FF) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          ),
        ));
        day++;
      }
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormat('yyyy년 M월').format(displayedMonth),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ..._buildDayLabels(),
                ..._buildDateCells(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff69B7FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    widget.onDateSelected(selectedDate);
                    Navigator.pop(context);
                  },
                  child: const Text('확인'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
