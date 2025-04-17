import 'package:cloud_firestore/cloud_firestore.dart';

class GymBookingModel {
  final Map<String, String> sportsTranslation = {
    "축구장": "SCCR",
    "농구장": "BKB",
    "배드민턴장": "BMT",
    "테니스장": "TNS",
    "탁구장": "TBTNS",
    "야구장": "BSB",
    "풋살장": "FTS",
    "수영장": "PL",
    "골프장": "GLF"
  };

  Future<void> saveReservationToFirestore(
      String gymId, String gymAbbreviation, String userId, DateTime selectedDate, String selectedTime, String sportsSummary, int price) async {
    final formattedDate = "${selectedDate.toLocal()}".split(' ')[0];
    final formattedCreateTime = selectedDate.toLocal().toIso8601String();
    final translatedSportsSummary = translateSportsSummary(sportsSummary);

    DocumentReference reservationDoc = FirebaseFirestore.instance.collection('reservations').doc("${formattedDate}_${selectedTime}_${gymId}_${translatedSportsSummary}_${userId}");
    await reservationDoc.set({
      'ceatetime': formattedCreateTime, // 생성 시간
      'date': formattedDate, // 날짜
      'gymAbbrevation': gymAbbreviation, // 체육관 약어
      'gymid': gymId, // 체육관 ID
      'sports': {
        'price': price, // 가격
        'sportname': translatedSportsSummary // 운동 종목
      },
      'status': true, // 상태
      'time': selectedTime, // 선택한 시간
      'userid': userId, // 사용자 ID
    });
  }

  String translateSportsSummary(String sportsSummary) {
    List<String> sportsList = sportsSummary.split(', ');
    List<String> translatedList = sportsList.map((sport) => sportsTranslation[sport.trim()] ?? sport).toList();
    return translatedList.join("_");
  }
}