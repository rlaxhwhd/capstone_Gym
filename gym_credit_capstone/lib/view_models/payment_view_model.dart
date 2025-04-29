import 'package:gym_credit_capstone/data/repositories/gym_Info_repository.dart';

class PaymentViewModel {
  final GymInfoRepository repository = GymInfoRepository();

  Future<int> fetchCost(String gymId, String selectedSport) async {
    Map<String, dynamic>? data = await repository.fetchGymDetails(gymId);
    if (data != null && data.containsKey('종목')) {
      Map<String, dynamic> sports = data['종목'];
      return sports[selectedSport];
    }
    throw Exception('종목 데이터를 가져올 수 없습니다.');
  }

  Future<String> fetchLocation(String gymId) async {
    Map<String, dynamic>? data = await repository.fetchGymDetails(gymId);
    if (data != null && data.containsKey('도로명')) {
      return data['도로명'];
    }
    throw Exception('도로명 데이터를 가져올 수 없습니다.');
  }
}