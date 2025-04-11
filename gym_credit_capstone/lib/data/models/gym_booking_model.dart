import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GymBookingModel {
  // 한글 스포츠 이름을 영어로 변환하는 매핑 테이블
  final Map<String, String> sportsTranslation = {
    "축구장": "Soccer",
    "농구장": "Basketball",
    "배드민턴장": "Badminton",
    "테니스장": "Tennis",
    "탁구장": "TableTennis",
    "야구장": "Baseball",
    "풋살장": "Futsal",
    "수영장": "Pool",
    // 필요시 추가
  };

  Future<Map<String, dynamic>?> fetchGymDetails(String gymId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot doc = await firestore.collection('Gym_list').doc(gymId).get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> saveReservationToFirestore(
      String gymId,
      String userId,
      DateTime selectedDate,
      String selectedTime,
      String sportsSummary,
      double totalPrice,
      ) async {
    final nowInUTCPlus9 = DateTime.now().toUtc().add(const Duration(hours: 9));
    final formattedCreateTime = "${nowInUTCPlus9.toLocal()} UTC+9";
    final formattedDate = "${selectedDate.toLocal()}".split(' ')[0];

    // sportsSummary를 영어로 변환
    final translatedSportsSummary = translateSportsSummary(sportsSummary);

    // 문서 이름 생성: date + gymId + 영어로 변환된 sportsSummary + userId
    final documentName = "${formattedDate}_${DateFormat('HH:mm:ss').format(nowInUTCPlus9)}_${translatedSportsSummary}_${userId}";

    DocumentReference reservationDoc = FirebaseFirestore.instance.collection('reservations').doc(documentName);
    await reservationDoc.set({
      'createtime': formattedCreateTime,
      'date': formattedDate,
      'gymid': gymId,
      'sports': {
        'price': totalPrice,
        'sport': sportsSummary, // 영어로 변환된 sportsSummary 저장
      },
      'status': true,
      'time': selectedTime,
      'userid': userId,
    });
  }

  // sportsSummary를 영어로 변환하는 메서드
  String translateSportsSummary(String sportsSummary) {
    List<String> sportsList = sportsSummary.split(', ');
    List<String> translatedList = [];

    //print(sportsList);

    for (String sport in sportsList)
    {
      /*print(sport.toString());
      print(sportsTranslation);
      print(sportsTranslation["축구장"]);*/
      translatedList.add(sportsTranslation[sport.toString().trim()] ?? sport);
    }

    String result = "";

    for(int i = 0; i < translatedList.length; i++) {
      result += translatedList[i];

      if(i < translatedList.length - 1)
        result += "_";
    }

    return result; // 변환된 각 스포츠 값을 리스트로 반환
  }
}