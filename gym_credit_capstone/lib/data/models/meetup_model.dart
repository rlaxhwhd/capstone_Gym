// data/models/meetup_model.dart

class Meetup {
  final String meetupId;  // 문서 ID (FireStore key)
  final String gymName;   // 체육관명
  final String title;     // 모임명 or 모임 설명 (ex: "불금에 배드민턴 치실때까지")
  final DateTime meetupTime;  // 모임 시간
  final int capacity;     // 모임 인원
  final DateTime createdAt;

  Meetup({
    required this.meetupId,
    required this.gymName,
    required this.title,
    required this.meetupTime,
    required this.capacity,
    required this.createdAt,
  });

  // Firestore 문서 -> Meetup 객체
  factory Meetup.fromMap(Map<String, dynamic> map, String docId) {
    return Meetup(
      meetupId: docId,
      gymName: map['gymName'] ?? '',
      title: map['title'] ?? '',
      meetupTime: DateTime.parse(map['meetupTime'] ?? DateTime.now().toIso8601String()),
      capacity: map['capacity'] ?? 0,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Meetup 객체 -> Firestore 문서
  Map<String, dynamic> toMap() {
    return {
      'gymName': gymName,
      'title': title,
      'meetupTime': meetupTime.toIso8601String(),
      'capacity': capacity,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
