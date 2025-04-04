import 'package:flutter/material.dart';
import '../data/repositories/gym_Info_repository.dart';
import '../data/models/gym_info_model.dart';

class FilteredGymViewModel extends ChangeNotifier {
  final GymInfoRepository gymInfoRepository; // Repository 연결
  List<GymInfo> filteredGyms = []; //

  // 생성자에서 gymInfoRepository를 받음
  FilteredGymViewModel({required this.gymInfoRepository});

  Future<void> filterGymsBySports(List<String> selectedSports) async {
    try {
      final allGyms = await gymInfoRepository.getAllGyms(); // 모든 체육관 가져오기

      filteredGyms = allGyms.where((gym) {
        return selectedSports.any((sport) => gym.sports.containsKey(sport) ?? false);
      }).cast<GymInfo>().toList();

      notifyListeners(); // UI 업데이트
    } catch (e) {
      print("Error filtering gyms: $e");
    }
  }
}