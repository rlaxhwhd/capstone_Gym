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

/*import 'package:cloud_firestore/cloud_firestore.dart';

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

  String gymAbbreviation = "";

  Future<Map<String, int>> checkReservationLimit(String gymId, List<DateTime> availableDates, List<String> availableTimes, String sportsSummary) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final gymDetails = await fetchGymDetails(gymId);
    final gymAbbreviation = gymDetails?['약자'] ?? 'UnknownGym';
    final translatedSportsSummary = translateSportsSummary(sportsSummary);

    Map<String, int> reservationCounts = {};

    print("날짜 검사 시작 (${availableDates.length}개)");

    for (DateTime date in availableDates) {
      String formattedDate = "${date.toLocal()}".split(' ')[0];

      print("formattedDate: ${formattedDate}");

      // 🔹 해당 날짜의 모든 예약 가져오기
      final QuerySnapshot querySnapshot = await firestore.collection('reservations')
          .where("date", isEqualTo: formattedDate) // 🔹 전체 날짜의 모든 문서 가져오기
          .get();

      List<QueryDocumentSnapshot> docs = querySnapshot.docs;

      print("시간 검사 시작 (${availableTimes.length}개)");

      for (String time in availableTimes) {
        String documentPrefix = "${formattedDate}_${time}_${gymAbbreviation}_${translatedSportsSummary}";

        print("documentPrefix: ${documentPrefix}");

        // 🔹 해당 시간과 관련된 예약 개수 확인
        int count = docs.where((doc) => doc.id.startsWith(documentPrefix)).length;

        reservationCounts[documentPrefix] = count; // 🔹 해당 조합의 예약 개수 저장
        print("예약 조합: $documentPrefix → 예약 개수: $count");
      }
    }

    return reservationCounts;
  }

  Future<String> fetchGymAbbreviation(String gymName) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot doc = await firestore.collection('Gym_list').doc(gymName).get(); // 🔹 문서 ID를 gymName으로 참조

    if (doc.exists) {
      Map<String, dynamic> gymData = doc.data() as Map<String, dynamic>; // 🔹 Object → Map으로 변환
      print("GymData[약자]: ${gymData['약자']}");
      return gymData['약자'] ?? 'UnknownGym'; // 🔹 약자 필드 가져오기
    }
    return 'UnknownGym';
  }

  Future<Map<String, dynamic>?> fetchGymDetails(String gymId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot doc = await firestore.collection('Gym_list').doc(gymId).get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<String>> fetchGymSports(String gymId) async {
    final gymDetails = await fetchGymDetails(gymId);
    if (gymDetails != null && gymDetails.containsKey('종목')) {
      return List<String>.from(gymDetails['종목'].keys);
    }
    return [];
  }

  Future<String> generateDocumentName(
      String gymId, String userId, DateTime selectedDate, String selectedTime, String sportsSummary) async {
    final formattedDate = "${selectedDate.toLocal()}".split(' ')[0];

    // 🔹 종목을 영어 버전으로 변환
    final translatedSportsSummary = translateSportsSummary(sportsSummary);

    // 체육관 정보 가져오기
    final gymDetails = await fetchGymDetails(gymId);
    gymAbbreviation = gymDetails?['약자'] ?? 'UnknownGym'; // 약어가 없으면 기본값 설정

    // 🔹 문서 이름 생성: date + selectedTime + gymAbbreviation + 영어 버전의 종목 + userId
    return "${formattedDate}_${selectedTime}_${gymAbbreviation}_${translatedSportsSummary}_${userId}";
  }

  Future<void> saveReservationToFirestore(
      String gymId, String userId, DateTime selectedDate, String selectedTime, String sportsSummary, double totalPrice) async {
    final documentName = await generateDocumentName(gymId, userId, selectedDate, selectedTime, sportsSummary);

    DocumentReference reservationDoc = FirebaseFirestore.instance.collection('reservations').doc(documentName);
    await reservationDoc.set({
      'createtime': "${DateTime.now().toUtc().add(const Duration(hours: 9)).toLocal()} UTC+9",
      'date': "${selectedDate.toLocal()}".split(' ')[0],
      'gymAbbreviation': gymAbbreviation,
      'gymid': gymId,
      'sports': {
        'price': totalPrice, // 🔹 가격 올바르게 저장
        'sport': sportsSummary, // 🔹 영어 번역된 종목 저장
      },
      'status': true,
      'time': selectedTime,
      'userid': userId,
    });
  }

  String translateSportsSummary(String sportsSummary) {
    List<String> sportsList = sportsSummary.split(', ');
    List<String> translatedList = [];

    for (String sport in sportsList) {
      translatedList.add(sportsTranslation[sport.trim()] ?? sport);
    }

    return translatedList.join("_"); // 🔹 변환된 종목을 "_"로 구분하여 저장
  }
}*/