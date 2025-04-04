import 'package:flutter/material.dart';

class MainViewModel extends ChangeNotifier {
  int _currentIndex = 0; // 현재 선택된 탭
  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    _currentIndex = index;
    notifyListeners(); // UI 업데이트
  }
}
