import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gym_info_model.dart';

class GymInfoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'Gym_list'; // 체육관 정보를 저장한 Firestore 컬렉션 이름

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


  //id목록으로 체육관 정보들 불러오기
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

  //특정 체육관Id로 정보 가져오기
  Future<GymInfo?> getGymById(String gymId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collectionPath).doc(gymId).get();

      if (doc.exists) {
        return GymInfo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print("Error fetching gym by ID: $e");
      return null;
    }
  }

  //모든 체육관 불러오기
  Future<List<GymInfo>> getAllGyms() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(_collectionPath).get();

      return querySnapshot.docs
          .map(
            (doc) =>
                GymInfo.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print("Error fetching all gyms: $e");
      return [];
    }
  }
}
