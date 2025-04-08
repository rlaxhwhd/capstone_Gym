// view_models/selected_sports_list_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:gym_credit_capstone/data/models/gym_info_model.dart';
import 'package:gym_credit_capstone/data/repositories/gym_Info_repository.dart';

class SelectedSportsListViewModel extends ChangeNotifier {
  final GymInfoRepository gymInfoRepository;

  List<GymInfo> _gymList = [];
  List<GymInfo> get gymList => _gymList;

  // 필터 상태: 무료/예약가능 선택 여부
  bool isFreeSelected = false;
  bool isReservableSelected = false;

  SelectedSportsListViewModel({required this.gymInfoRepository});

  // 체육관 조회: 선택된 종목에 해당하는 체육관 목록을 Repository에서 가져온 후, 내부 리스트에 저장
  Future<void> fetchGymList(List<String> selectedSports) async {
    _gymList = await gymInfoRepository.getGymsBySports(selectedSports);
    notifyListeners();
  }


  // 무료/예약가능 필터를 적용한 체육관 목록 반환
  List<GymInfo> get filteredGyms {
    // 필터를 적용하지 않으면 전체 목록 반환
    if (!isFreeSelected && !isReservableSelected) return _gymList;
    return _gymList.where((gym) {
      // 무료 필터: 무료만 표시하길 원한다면, isFreeSelected가 true일 때 유료 체육관 제외
      if (isFreeSelected && gym.isPaid) {
        return false;
      }
      // 예약가능 필터: 이번 예시에서는 항상 '예약가능'으로 처리하므로 따로 체크하지 않음
      return true;
    }).toList();
  }

  void toggleFreeFilter() {
    isFreeSelected = !isFreeSelected;
    notifyListeners();
  }

  // 예약가능 필터는 UI 토글만 전달(현재 모든 체육관이 예약가능으로 처리됨)
  void toggleReservableFilter() {
    isReservableSelected = !isReservableSelected;
    notifyListeners();
  }
}
