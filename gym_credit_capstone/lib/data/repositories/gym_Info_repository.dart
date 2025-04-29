import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gym_info_model.dart';

class GymInfoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'Gym_list';

  Future<GymInfo?> getGymById(String gymId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collectionPath).doc(gymId).get();
      return doc.exists ? GymInfo.fromMap(doc.data() as Map<String, dynamic>, doc.id) : null;
    } catch (e) {
      print("Error fetching gym by ID: $e");
      return null;
    }
  }

  Future<List<GymInfo>> getGymsByIds(List<String> gymIds) async {
    try {
      if (gymIds.isEmpty) return [];

      QuerySnapshot querySnapshot =
      await _firestore
          .collection(_collectionPath)
          .where(FieldPath.documentId, whereIn: gymIds)
          .get();

      return querySnapshot.docs
          .map(
            (doc) =>
            GymInfo.fromMap(doc.data() as Map<String, dynamic>, doc.id),
      )
          .toList();
    } catch (e) {
      print("Error fetching gyms by IDs: $e");
      return [];
    }
  }

  Future<List<GymInfo>> getGymsBySports(List<String> selectedSports) async {
    try {
      // 전체 체육관 불러오기
      final gymsSnapshot = await _firestore.collection(_collectionPath).get();

      final gyms = gymsSnapshot.docs
          .map((doc) => GymInfo.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // 선택된 모든 종목을 포함한 체육관만 필터링 (AND 조건)
      final filteredGyms = gyms.where((gym) {
        return selectedSports.every((sport) => gym.sports.containsKey(sport));
      }).toList();

      return filteredGyms;
    } catch (e) {
      print("Error fetching gyms by sports: $e");
      return [];
    }
  }

  Future<List<GymInfo>> getAllGyms() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(_collectionPath).get();
      return querySnapshot.docs.map((doc) => GymInfo.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print("Error fetching all gyms: $e");
      return [];
    }
  }

  Future<List<String>> fetchGymSports(String gymId) async {
    final gymDetails = await fetchGymDetails(gymId);
    if (gymDetails != null && gymDetails.containsKey('종목')) {
      return List<String>.from(gymDetails['종목'].keys);
    }
    return [];
  }

  Future<Map<String, dynamic>?> fetchGymDetails(String gymId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot doc = await firestore.collection('Gym_list').doc(gymId).get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<String> fetchGymAbbreviation(String gymName) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot doc = await firestore.collection('Gym_list').doc(
        gymName).get(); // 🔹 문서 ID를 gymName으로 참조

    if (doc.exists) {
      Map<String, dynamic> gymData = doc.data() as Map<String,
          dynamic>; // 🔹 Object → Map으로 변환
      print("GymData[약자]: ${gymData['약자']}");
      return gymData['약자'] ?? 'UnknownGym'; // 🔹 약자 필드 가져오기
    }
    return 'UnknownGym';
  }

  /*Future<Map<String, dynamic>?> getGymDataFromFirestoreForPayment() async {
    // Firestore instance 초기화
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Gym_list 컬렉션에서 gymName에 해당하는 문서 참조
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await firestore.collection('Gym_list').doc(widget.gymId).get();

    // 문서 데이터 가져오기
    return documentSnapshot.data();
  }*/
}
