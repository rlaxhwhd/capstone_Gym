class Reservation {
  final String gym;
  final String date;
  final String time;
  final int amount;
  final String sports;

  Reservation({
    required this.gym,
    required this.date,
    required this.time,
    required this.amount,
    required this.sports,
  });

  factory Reservation.fromMap(Map<String, dynamic> data) {
    final date = data['date'] ?? '';
    final time = data['time']?.toString() ?? '';
    final gym = data['gymId'] ?? '';
    final sports = data['sports']?['sportName'] ?? '';
    final price = data['sports']?['price'];

    int amount = 0;
    if (price is int) {
      amount = price;
    } else if (price is double) {
      amount = price.toInt();
    }

    return Reservation(
      gym: gym,
      date: date,
      time: time,
      amount: amount,
      sports: sports,
    );
  }
}