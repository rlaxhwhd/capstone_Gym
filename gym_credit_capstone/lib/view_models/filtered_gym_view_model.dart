import 'package:flutter/material.dart';
import '../data/repositories/gym_Info_repository.dart';
import '../data/models/gym_info_model.dart';

class FilteredGymViewModel extends ChangeNotifier {
  final GymInfoRepository gymInfoRepository; // Repository 연결
  List<GymInfo> filteredGyms = []; // 필터링된 체육관 리스트 저장

  // 생성자에서 GymInfoRepository를 받음
  FilteredGymViewModel({required this.gymInfoRepository});

  /// 스포츠 기준으로 체육관 필터링
  Future<void> filterGymsBySports(List<String> selectedSports) async {
    try {
      // 모든 체육관 데이터 가져오기
      final allGyms = await gymInfoRepository.getAllGyms();

      // 필터링 로직 적용
      filteredGyms = allGyms.where((gym) {
        return selectedSports.any((sport) => gym.sports.containsKey(sport) ?? false);
      }).cast<GymInfo>().toList();

      // 필터링 결과 출력 (디버깅용)
      for (var gym in filteredGyms) {
        print('Filtered Gym: ${gym.name}');
      }

      // UI 업데이트
      notifyListeners();
    } catch (e) {
      // 에러 발생 시 처리
      print("Error filtering gyms: $e");
    }
  }
}