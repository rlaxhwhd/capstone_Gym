// data/repositories/meetup_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_credit_capstone/data/models/meetup_model.dart';

class MeetupRepository {
  final _db = FirebaseFirestore.instance;

  // 모임 등록
  Future<void> createMeetup(Meetup meetup) async {
    final docRef = _db.collection('meetups').doc(); // 새 문서 ID 자동 생성
    final newMeetup = meetup.copyWith(meetupId: docRef.id);

    await docRef.set(newMeetup.toMap());
  }

  // 전체 모임 불러오기
  Future<List<Meetup>> getAllMeetups() async {
    final snapshot = await _db.collection('meetups').get();
    return snapshot.docs.map((doc) {
      return Meetup.fromMap(doc.data(), doc.id);
    }).toList();
  }
}

// 필요하다면 copyWith를 사용해 meetupId 설정 가능
extension MeetupCopyWith on Meetup {
  Meetup copyWith({
    String? meetupId,
    String? gymName,
    String? title,
    DateTime? meetupTime,
    int? capacity,
    DateTime? createdAt,
  }) {
    return Meetup(
      meetupId: meetupId ?? this.meetupId,
      gymName: gymName ?? this.gymName,
      title: title ?? this.title,
      meetupTime: meetupTime ?? this.meetupTime,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
