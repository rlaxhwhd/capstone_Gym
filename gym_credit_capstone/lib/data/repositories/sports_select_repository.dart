import 'package:cloud_firestore/cloud_firestore.dart';

class SportsSelectRepository {
  final FirebaseFirestore _firestore;

  SportsSelectRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<int> fetchSportMap(String gymId, String sport) async {
    try {
      // Firestore의 "Gym_list" 컬렉션에서 gymId에 해당하는 문서를 가져옴
      DocumentSnapshot doc = await _firestore.collection("Gym_list").doc(gymId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey("종목")) {
          // "종목" 필드를 Map으로 변환하여 반환
          Map result = Map<String, dynamic>.from(data["종목"]);
          return result[sport];
        }
      }
      return 0;
    } catch (e) {
      print("Error fetching sport map for gymId $gymId: $e");
      return 0;
    }
  }
}