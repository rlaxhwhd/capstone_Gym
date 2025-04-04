import 'package:flutter/material.dart';
import '../data/models/home_events_card_model.dart';
import '../data/repositories/home_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository = HomeRepository();
  List<HomeEvent> _events = [];
  late String id = "";
  Future<List<HomeEvent>>? _eventsFuture;  // Future<List<HomeEvent>>로 수정

  List<HomeEvent> get events => _events;
  Future<List<HomeEvent>>? get eventsFuture => _eventsFuture;  // Future<List<HomeEvent>> 타입

  Future<void> loadEvents() async {
    if (_eventsFuture != null) return;  // 이미 실행된 경우 다시 실행 방지

    _eventsFuture = _fetchAndNotify();  // Future<List<HomeEvent>> 실행
  }

  Future<List<HomeEvent>> _fetchAndNotify() async {  // 반환 타입을 List<HomeEvent>로 수정
    print("loadEvents() 실행 시작");
    _events = await _repository.fetchHomeEvents();
    print("events 가져옴: ${_events.length}개");
    notifyListeners();
    print("notifyListeners() 호출 완료");
    return _events;  // 반환값 추가
  }
}