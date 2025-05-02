class Reservation {
  final String gymId;
  final String time;
  final String date;
  final String docId;
  final bool status;

  Reservation({
    required this.gymId,
    required this.time,
    required this.date,
    required this.docId,
    required this.status,
  });

  factory Reservation.fromMap(Map<String, dynamic> map, String docId) {
    return Reservation(
      gymId: map['gymId'],
      time: map['time'],
      date: map['date'],
      docId: docId,
      status: map['status'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gymId': gymId,
      'time': time,
      'date': date,
      'status': status,
    };
  }

  @override
  String toString() {
    return "Reservation(날짜: $date, 시간: $time, 장소: $gymId)";
  }
}