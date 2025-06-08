import 'package:flutter/material.dart';
import '../data/repositories/user_repository.dart';

class BackgroundViewModel extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  String? _nickname;

  String? get nickname => _nickname;

  Future<void> loadNickname(String uid) async {
    try {
      _nickname = await _repository.getUserNickname(uid);
      notifyListeners(); // 상태 업데이트
    } catch (e) {
      print('닉네임 로드 오류: $e');
    }
  }
}
