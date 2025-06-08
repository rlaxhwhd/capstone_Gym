import 'package:flutter/material.dart';

class CheckBoxList extends StatelessWidget{
  final String termTitle;
  final VoidCallback onCheckBoxTap;
  final bool boolValue;
  final VoidCallback? onTermsTap;

  CheckBoxList({
    super.key,
    required this.termTitle,
    required this.onCheckBoxTap,
    required this.boolValue,
    this.onTermsTap,
  });

  // boolValue가 null이면 true, 아니면 false를 반환하는 계산된 속성
  bool get isNotNull => onTermsTap != null;

  @override
  Widget build(BuildContext context){
    return Row(
      children: [
        GestureDetector(
          onTap: onCheckBoxTap, // 체크 상태 토글 (체크박스 영역),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Transform.scale(
              scale: 1.5,
              child: AbsorbPointer(
                child: Checkbox(
                  value: boolValue,
                  onChanged: (value) {}, // AbsorbPointer로 인해 호출되지 않음
                  activeColor: const Color(0xff69B7FF),
                  checkColor: Colors.white,
                  side: const BorderSide(color: Color(0xff69B7FF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onCheckBoxTap, // 체크 상태 토글 (텍스트 영역),
            child: Text(termTitle, style: TextStyle(fontSize: 18, fontFamily: 'NanumSquare', fontWeight: FontWeight.w700)),
          ),
        ),
        if(isNotNull)
          GestureDetector(
            onTap: onTermsTap,
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.arrow_forward_ios, size: 20.0),
            ),
          ),
      ],
    );
  }

}