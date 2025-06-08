import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/data/models/gym_info_model.dart';
import 'package:gym_credit_capstone/data/repositories/gym_info_repository.dart';
import 'package:gym_credit_capstone/data/repositories/user_repository.dart';// ✅ GeoPoint를 위한 Firebase import

class LikedGymViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final GymInfoRepository _gymInfoRepository;

  List<GymInfo> _likedGyms = [];
  bool _isLoading = false;

  bool _hasFavorites = false;
  bool get hasFavorites => _hasFavorites;

  List<GymInfo> get likedGyms => _likedGyms;
  bool get isLoading => _isLoading;

  LikedGymViewModel({
    required UserRepository userRepository,
    required GymInfoRepository gymInfoRepository,
  })  : _userRepository = userRepository,
        _gymInfoRepository = gymInfoRepository;

  // LikedGymViewModel에 추가
  Future<void> fetchLikedGyms() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<String> likedGymIds = await _userRepository.getLikedGymIds();

      if (likedGymIds.isEmpty) {
        // 좋아요한 체육관이 없으면 랜덤 체육관 표시
        _hasFavorites = false;
        await fetchRandomGyms();
      } else {
        // 좋아요한 체육관이 있으면 해당 체육관들 표시
        _likedGyms = await _gymInfoRepository.getGymsByIds(likedGymIds);
        _hasFavorites = true;
      }
    } catch (e) {
      print("Error fetching gyms for home: $e");
      _likedGyms = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 전체 체육관 목록 불러와서 3개
  Future<void> fetchRandomGyms() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<String> allGymIds = await _gymInfoRepository.getAllGymIdsOnly();
      allGymIds.shuffle();

      List<String> randomGymIds = allGymIds.length <= 3
          ? allGymIds
          : allGymIds.take(3).toList();
      _likedGyms = await _gymInfoRepository.getGymsByIds(randomGymIds);

    } catch (e) {
      print("Error fetching liked gyms info: $e");
      _likedGyms = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 특정 체육관이 좋아요된 상태인지 확인
  bool isGymLiked(String gymId) {
    return _likedGyms.any((gym) => gym.name == gymId);
  }



}
