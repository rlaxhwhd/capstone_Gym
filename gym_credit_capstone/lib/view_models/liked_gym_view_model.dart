import 'package:flutter/material.dart';
import '../data/models/gym_info_model.dart';
import '../data/repositories/gym_info_repository.dart';
import '../data/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ GeoPoint를 위한 Firebase import

class LikedGymViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final GymInfoRepository _gymInfoRepository;

  List<GymInfo> _likedGyms = [];
  bool _isLoading = false;

  List<GymInfo> get likedGyms => _likedGyms;
  bool get isLoading => _isLoading;

  LikedGymViewModel({
    required UserRepository userRepository,
    required GymInfoRepository gymInfoRepository,
  })  : _userRepository = userRepository,
        _gymInfoRepository = gymInfoRepository;

  /// 좋아요한 체육관 목록 불러오기
  Future<void> fetchLikedGyms() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<String> likedGymIds = await _userRepository.getLikedGymIds();
      _likedGyms = await _gymInfoRepository.getGymsByIds(likedGymIds);
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

  /// 좋아요 토글 기능
  Future<void> toggleFavoriteGym(String gymId) async {
    bool previousState = isGymLiked(gymId);

    if (previousState) {
      _likedGyms.removeWhere((gym) => gym.name == gymId);
    } else {
      GymInfo? gym = await _gymInfoRepository.getGymById(gymId);
      if (gym != null) {
        _likedGyms.add(gym);
      }
    }

    notifyListeners();

    try {
      await _userRepository.toggleLikedGym(gymId);
    } catch (e) {
      print("Error toggling favorite: $e");
      if (previousState) {
        _likedGyms.add(
          GymInfo(
            name: gymId,
            location: '',
            imageUrl: '',
            facilityHours: '정보 없음', // ✅ String 타입으로 수정
            tel: '정보 없음',
            coord: GeoPoint(0.0, 0.0), // ✅ GeoPoint로 수정
            isPaid: false,
            isMembership: false,
            sports: {},
            gymFacility: {},
          ),
        );
      } else {
        _likedGyms.removeWhere((gym) => gym.name == gymId);
      }
      notifyListeners();
    }
  }
}