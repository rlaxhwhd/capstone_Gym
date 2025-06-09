import 'package:flutter/material.dart';

enum LabelType { numType, textSmall, textBig }

class LabeledTextRow extends StatelessWidget {
  final LabelType labelType;
  final List<String> textList;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;

  const LabeledTextRow({
    Key? key,
    required this.labelType,
    required this.textList,
    this.textStyle,
    this.labelStyle,
  }) : super(key: key);

  static const Map<LabelType, List<String>> _labelMap = {
    LabelType.numType: [
      '①','②','③','④','⑤','⑥','⑦','⑧','⑨','⑩',
      '⑪','⑫','⑬','⑭','⑮','⑯','⑰','⑱','⑲','⑳',
    ],
    LabelType.textSmall: ['·'],
    LabelType.textBig: ['●'],
  };

  @override
  Widget build(BuildContext context) {
    final labels = _labelMap[labelType]!;

    return DefaultTextStyle(
      style: textStyle ?? TextStyle(
        fontFamily: 'NanumSquare',
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(textList.length, (index) {
          final label = index < labels.length ? labels[index] : _fallbackLabel(index);
          final text = textList[index];
          final isLongText = text.length > 24;
          final spacing = isLongText ? 9.0 : 4.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: labelStyle ?? const TextStyle(fontSize: 25)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),
            ],
          );
        }),
      ),
    );
  }

  // 라벨 범위를 넘었을 때 대체 문자열 생성
  String _fallbackLabel(int index) {
    switch (labelType) {
      case LabelType.numType:
        return '${index + 1}.';
      case LabelType.textBig:
        return '●';
      case LabelType.textSmall:
      default:
        return '·';
    }
  }
}