// view_models/meetup_view_model.dart
import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/data/models/meetup_model.dart';
import 'package:gym_credit_capstone/data/repositories/meetup_repository.dart';

class MeetupViewModel extends ChangeNotifier {
  final MeetupRepository _repository;
  MeetupViewModel(this._repository);

  List<Meetup> _meetups = [];
  List<Meetup> get meetups => _meetups;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 전체 모임 불러오기
  Future<void> fetchAllMeetups() async {
    _isLoading = true;
    notifyListeners();

    _meetups = await _repository.getAllMeetups();

    _isLoading = false;
    notifyListeners();
  }

  // 모임 등록
  Future<void> createMeetup({
    required String gymName,
    required String title,
    required DateTime meetupTime,
    required int capacity,
  }) async {
    final newMeetup = Meetup(
      meetupId: '', // Firestore에서 생성 후 copyWith로 설정
      gymName: gymName,
      title: title,
      meetupTime: meetupTime,
      capacity: capacity,
      createdAt: DateTime.now(),
    );

    await _repository.createMeetup(newMeetup);

    // 성공 후, 다시 목록을 불러오거나 (간단히) 직접 리스트에 추가
    _meetups.add(newMeetup);
    notifyListeners();
  }
}
