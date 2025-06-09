import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/style/custom_colors.dart';

class CustomWheelDatePickerField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const CustomWheelDatePickerField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  State<CustomWheelDatePickerField> createState() =>
      _CustomWheelDatePickerFieldState();
}

class _CustomWheelDatePickerFieldState
    extends State<CustomWheelDatePickerField> {
  int selectedYear = 2000;
  int selectedMonth = 1;
  int selectedDay = 1;

  final double _itemExtent = 40.0;

  // 연도, 월, 일 리스트
  List<int> get years => List.generate(100, (i) => DateTime.now().year - i);
  List<int> get months => List.generate(12, (i) => i + 1);
  List<int> get days => List.generate(31, (i) => i + 1);

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 상단 핸들바
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 헤더 영역
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '생년월일 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'NanumSquare',
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: CustomColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: CustomColors.primaryColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        final y = selectedYear;
                        final m = selectedMonth.toString().padLeft(2, '0');
                        final d = selectedDay.toString().padLeft(2, '0');
                        final newDate = '$y-$m-$d';

                        widget.controller.text = newDate;

                        // onChanged 콜백 호출
                        if (widget.onChanged != null) {
                          widget.onChanged!(newDate);
                        }

                        Navigator.pop(context);

                        FocusScope.of(context).unfocus();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontFamily: 'NanumSquare',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 휠 선택 영역
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 연 휠 영역
                  SizedBox(
                    width: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(
                            initialItem: years.indexOf(selectedYear),
                          ),
                          itemExtent: _itemExtent,
                          onSelectedItemChanged: (i) =>
                              setState(() => selectedYear = years[i]),
                          physics: const FixedExtentScrollPhysics(),
                          diameterRatio: 1.5,
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (_, idx) {
                              if (idx < 0 || idx >= years.length)
                                return null;
                              return Center(
                                child: Text(
                                  '${years[idx]}년',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'NanumSquare',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              );
                            },
                            childCount: years.length,
                          ),
                        ),
                        // 선택 영역 표시
                        Positioned(
                          top: 81,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            color: CustomColors.primaryColor,
                          ),
                        ),
                        Positioned(
                          bottom: 81,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            color: CustomColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 월 휠 영역
                  SizedBox(
                    width: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(
                            initialItem: selectedMonth - 1,
                          ),
                          itemExtent: _itemExtent,
                          onSelectedItemChanged: (i) =>
                              setState(() => selectedMonth = months[i]),
                          physics: const FixedExtentScrollPhysics(),
                          diameterRatio: 1.5,
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (_, idx) {
                              if (idx < 0 || idx >= months.length)
                                return null;
                              return Center(
                                child: Text(
                                  '${months[idx]}월',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'NanumSquare',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              );
                            },
                            childCount: months.length,
                          ),
                        ),
                        // 선택 영역 표시
                        Positioned(
                          top: 81,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            color: CustomColors.primaryColor,
                          ),
                        ),
                        Positioned(
                          bottom: 81,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            color: CustomColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 일 휠 영역
                  SizedBox(
                    width: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(
                            initialItem: selectedDay - 1,
                          ),
                          itemExtent: _itemExtent,
                          onSelectedItemChanged: (i) => setState(() => selectedDay = days[i]),
                          physics: const FixedExtentScrollPhysics(),
                          diameterRatio: 1.5,
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (_, idx) {
                              if (idx < 0 || idx >= days.length)
                                return null;
                              return Center(
                                child: Text(
                                  '${days[idx]}일',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'NanumSquare',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              );
                            },
                            childCount: days.length,
                          ),
                        ),
                        // 선택 영역 표시
                        Positioned(
                          top: 81,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            color: CustomColors.primaryColor,
                          ),
                        ),
                        Positioned(
                          bottom: 81,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            color: CustomColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPicker,
      child: AbsorbPointer(
        child: TextFormField(
          controller: widget.controller,
          style: TextStyle(
            fontFamily: 'NanumSquare',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelStyle: TextStyle(
              fontFamily: 'NanumSquare',
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: CustomColors.primaryColor,
              size: 18,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: CustomColors.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(0, 13, 0, 8),
          ),
          // TextFormField의 onChanged는 AbsorbPointer로 인해 작동하지 않으므로 제거
        ),
      ),
    );
  }
}