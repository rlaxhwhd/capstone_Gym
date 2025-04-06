import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final double? width;
  final double? height;
  final double? fontSize;

  const TagWidget({
    super.key,
    required this.text,
    required this.bgColor,
    required this.textColor,
    this.width,
    this.height,
    this.fontSize,
  });

  TagWidget.bright(
      this.text, {
        this.width,
        this.height,
        this.fontSize,
        super.key,
      })  : bgColor = const Color(0x2b69b7ff),
        textColor = const Color(0xff69B7FF);

  TagWidget.normal(
      this.text, {
        this.width,
        this.height,
        this.fontSize,
        super.key,
      })  : bgColor = const Color(0xff69B7FF),
        textColor = const Color(0xffffffff);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 48,
      height: height ?? 25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: fontSize ?? 14, fontWeight: FontWeight.bold, fontFamily: 'nanumgothic'),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
