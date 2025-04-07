import 'package:flutter/material.dart';

class SelectedSportsList extends StatelessWidget {
  final List<String> selectedSports;

  const SelectedSportsList({Key? key, required this.selectedSports}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("선택한 스포츠")),
      body: Center(
        child: Text(
          selectedSports.isNotEmpty
              ? "선택한 스포츠: ${selectedSports.join(', ')}"
              : "선택한 스포츠가 없습니다.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
