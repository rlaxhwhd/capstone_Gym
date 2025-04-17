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

  // 모임 전체 불러오기 (필요 시)
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
      meetupId: '', // Firestore에서 새 문서를 생성할 때 교체할 예정
      gymName: gymName,
      title: title,
      meetupTime: meetupTime,
      capacity: capacity,
      createdAt: DateTime.now(),
    );

    await _repository.createMeetup(newMeetup);
    _meetups.add(newMeetup); // 필요 시 목록에 추가 (혹은 fetchAllMeetups() 호출)
    notifyListeners();
  }
}
