import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/style/custom_colors.dart';

class StepIndicator extends StatelessWidget {
  final int currentPage;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentPage,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps-1, (index) {
          final bool isCurrent = index == currentPage;
          final bool isCompleted = index < currentPage;

          Color circleColor;
          Color textColor;
          Color lineColor;

          if (isCurrent) {
            circleColor = CustomColors.primaryColor;
            textColor = Colors.white;
            lineColor = Colors.grey[300]!; // 이전 단계 선
          } else if (isCompleted) {
            circleColor = Colors.white;
            textColor = Colors.grey;
            lineColor = Colors.grey; // 완료된 선
          } else {
            circleColor = Colors.white;
            textColor = Colors.black;
            lineColor = Colors.grey[300]!; // 비활성 선
          }

          return Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                  border: Border.all(
                    color: isCurrent ? CustomColors.primaryColor : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (index != totalSteps - 2)
                Container(
                  width: 15,
                  height: 2,
                  color: lineColor, // 결정된 lineColor 사용
                ),
            ],
          );
        }),
      ),
    );
  }
}
