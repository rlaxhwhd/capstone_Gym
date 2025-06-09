// lib/view_models/meetup_view_model.dart

import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/data/models/meetup_model.dart';
import 'package:gym_credit_capstone/data/repositories/meetup_repository.dart';

class MeetupViewModel extends ChangeNotifier {
  final MeetupRepository _repository;

  MeetupViewModel(this._repository);

  // 로딩 상태
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // 불러온 모임 목록
  List<Meetup> _meetups = [];

  List<Meetup> get meetups => _meetups;

  /// 전체 모임을 Firestore 에서 가져와 [_meetups] 에 저장
  Future<void> fetchAllMeetups() async {
    _isLoading = true;
    notifyListeners();

    try {
      _meetups = await _repository.getAllMeetups();
    } catch (e) {
      debugPrint('Error fetching meetups: $e');
      _meetups = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 새로운 모임을 등록하고, 성공 시 리스트에 추가
  Future<void> createMeetup({
    required String gymName,
    required String title,
    required DateTime meetupTime,
    required int capacity,
  }) async {
    final newMeetup = Meetup(
      meetupId: '',
      gymName: gymName,
      title: title,
      meetupTime: meetupTime,
      capacity: capacity,
      createdAt: DateTime.now(),
    );

    _isLoading = true;
    notifyListeners();

    try {
      // Void를 반환하므로, 리턴값을 받지 않습니다.
      await _repository.createMeetup(newMeetup);
      // 성공 후 새로 만든 newMeetup을 리스트에 추가합니다.
      _meetups.add(newMeetup);
    } catch (e) {
      debugPrint('Error creating meetup: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
