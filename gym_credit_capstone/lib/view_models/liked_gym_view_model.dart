import 'package:flutter/material.dart';
import '../data/models/gym_info_model.dart';
import '../data/repositories/gym_Info_repository.dart';
import '../data/repositories/user_repository.dart';

class LikedGymViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final GymInfoRepository _gymInfoRepository;

  List<GymInfo> _likedGyms = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GymInfo> get likedGyms => _likedGyms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  GymInfo getGymInfoByIndex(int index) {
    if (index < 0 || index >= _likedGyms.length) {
      throw IndexError(index, _likedGyms);
    }
    return _likedGyms[index];
  }

  LikedGymViewModel({
    required UserRepository userRepository,
    required GymInfoRepository gymInfoRepository,
  })  : _userRepository = userRepository,
        _gymInfoRepository = gymInfoRepository;

  Future<void> fetchLikedGyms() async {
    _isLoading = true;
    notifyListeners();

    try {
      _likedGyms = await _gymInfoRepository.fetchLikedGyms(_userRepository);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

//수정 전 코드 ====>

/*class LikedGymViewModel extends ChangeNotifier {
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
}*/