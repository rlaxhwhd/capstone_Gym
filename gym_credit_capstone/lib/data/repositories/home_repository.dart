import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/home_events_card_model.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<HomeEvent>> fetchHomeEvents() async {
    try {
      // '헬스장' 가격이 1500인 체육관만 필터링하여 가져오기
      final querySnapshot = await _firestore
          .collection('Gym_list')
          .where('종목.헬스장', isEqualTo: 1500)
          .get(); // Firebase에서 데이터를 가져옴

      // 문서 데이터를 HomeEvent 모델로 매핑
      List<HomeEvent> events = querySnapshot.docs.map((doc) {
        return HomeEvent.fromMap(doc.data() as Map<String, dynamic>, doc.id);  // 문서 ID를 name으로 설정
      }).toList();

      return events;
    } catch (e) {
      print('Error fetching home events: $e');
      return [];
    }
  }
}
