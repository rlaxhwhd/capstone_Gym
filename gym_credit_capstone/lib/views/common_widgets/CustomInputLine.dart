import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/utils/addPostposition.dart';
import 'package:gym_credit_capstone/style/custom_colors.dart';
import 'package:flutter/services.dart';

class CustomInputLine extends StatefulWidget {
  final String hintTextValue;
  final TextEditingController controller;
  final String inputValue;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  // 새로 추가된 필드들
  final String? obscuringCharacter;
  final Widget? suffixIcon;
  final Widget? addSuffixIcon;
  final TextStyle? textStyle;
  final int? bottomLineWidth;
  final bool? enabled;

  const CustomInputLine({
    required this.hintTextValue,
    required this.controller,
    required this.inputValue,
    this.keyboardType,
    this.onChanged,
    this.obscuringCharacter,
    this.suffixIcon,
    this.addSuffixIcon,
    this.textStyle,
    this.bottomLineWidth,
    this.enabled,
    super.key,
  });

  @override
  State<CustomInputLine> createState() => _CustomInputLineState();
}

class _CustomInputLineState extends State<CustomInputLine> {
  late bool hasInput;
  bool _isPwVisible = false;

  @override
  void initState() {
    super.initState();
    hasInput = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_handleInputChange);
  }

  void _handleInputChange() {
    if (hasInput != widget.controller.text.isNotEmpty) {
      setState(() {
        hasInput = widget.controller.text.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleInputChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: CustomColors.primaryColor, // 커서 색상
          selectionColor: Color(0xd0cdcdcd), // 선택된 영역 배경색
          selectionHandleColor: Colors.transparent, // 핸들 색상
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        enabled: widget.enabled,
        obscureText:
            widget.hintTextValue.contains("비밀번호") ? !_isPwVisible : false,
        obscuringCharacter: widget.obscuringCharacter ?? '●',
        style: widget.textStyle,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: widget.hintTextValue,
          suffixIcon:
              widget.hintTextValue.contains("비밀번호")
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPwVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPwVisible = !_isPwVisible;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      if(widget.addSuffixIcon != null)
                        widget.addSuffixIcon!,
                    ],
                  )
                  : widget.suffixIcon,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontFamily: 'NanumSquare',
            fontWeight: FontWeight.w500,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: hasInput ? Colors.black : Color(0xc2d1d1d1),
              width: 1.1,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: hasInput ? Colors.black : Color(0xc2d1d1d1),
              width: 1.8,
            ),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.8),
          ),
        ),
        keyboardType: widget.keyboardType ?? TextInputType.text,
        inputFormatters: [
          if (widget.keyboardType == TextInputType.phone)
            FilteringTextInputFormatter.digitsOnly,
          if (widget.keyboardType == TextInputType.phone)
            PhoneNumberInputFormatter(),
        ],

        onChanged: widget.onChanged,
      ),
    );
  }
}

class PhoneNumberInputFormatter extends TextInputFormatter {
  // 숫자만 필터링 & 최대 11자리
  String _getDigitsOnly(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length > 11 ? digits.substring(0, 11) : digits;
  }

  // 전화번호 포맷팅
  String _formatNumber(String digits) {
    if (digits.length <= 3) {
      return digits;
    } else if (digits.length <= 6) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else if (digits.length <= 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    } else {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final oldDigits = _getDigitsOnly(oldValue.text);
    final newDigits = _getDigitsOnly(newValue.text);

    final formatted = _formatNumber(newDigits);

    // 커서 위치 계산
    int selectionIndex = newValue.selection.end;

    // 기존 커서 위치 기준으로 숫자와 하이픈 차이 계산
    int digitsBeforeCursor = 0;
    for (int i = 0; i < selectionIndex && i < newValue.text.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }

    // 새 포맷된 문자열에서 커서가 위치할 인덱스 찾기
    int newCursorPosition = 0;
    int digitsCounted = 0;
    while (digitsCounted < digitsBeforeCursor && newCursorPosition < formatted.length) {
      if (RegExp(r'[0-9]').hasMatch(formatted[newCursorPosition])) {
        digitsCounted++;
      }
      newCursorPosition++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}

bool isPasswordValid(String password) {
  final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
  final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
  final hasDigit = RegExp(r'\d').hasMatch(password);
  final hasSpecialChar = RegExp(r'[!@#\$%^&*]').hasMatch(password);
  final hasMinLength = password.length >= 8;

  return hasUpperCase &&
      hasLowerCase &&
      hasDigit &&
      hasSpecialChar &&
      hasMinLength;
}
