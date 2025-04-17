import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../data/models/gym_info_model.dart';
import '../data/repositories/gym_info_repository.dart';
import '../utils/distance_calculator.dart';
import '../data/repositories/text_repository.dart';

class GymDetailViewModel extends ChangeNotifier {
  final GymInfoRepository _gymInfoRepository = GymInfoRepository();
  GymInfo? _gymInfo;
  bool _isLoading = true;
  double? _distanceFromUser;

  GymInfo? get gymInfo => _gymInfo;
  bool get isLoading => _isLoading;
  String get formattedDistance => _distanceFromUser != null ? "${_distanceFromUser!.toStringAsFixed(2)} km" : "-";

  Future<void> fetchGymDetail(String gymId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _gymInfo = await _gymInfoRepository.getGymById(gymId);
      _calculateDistance();
    } catch (e) {
      print("Error fetching gym detail: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _calculateDistance() async {
    try {
      if (_gymInfo?.coord != null) {
        final location = Location();
        final userLocation = await location.getLocation();
        _distanceFromUser = DistanceCalculator.calculateKm(
          startLat: userLocation.latitude!,
          startLng: userLocation.longitude!,
          endLat: _gymInfo!.coord.latitude,
          endLng: _gymInfo!.coord.longitude,
        );
      }
    } catch (e) {
      print("Error calculating distance: $e");
    }
  }

  List<Map<String, dynamic>> _gymRules = [];
  List<Map<String, dynamic>> get gymRules => _gymRules;

  Future<void> loadGymRulesJson() async {
    try {
      _gymRules = await TextRepository().loadJsonListFromLocal(
          'assets/text/gym_rules.json');
      notifyListeners();
      print("gymRules: $_gymRules");
    } catch (e) {
      print("Error loading JSON: $e");
    }
  }

  /*String get formattedDistance {
    if (_isDistanceLoading) return "거리 계산 중...";
    if (_distanceFromUser != null) {
      return '현위치로부터 ${_distanceFromUser!.toStringAsFixed(2)} km';
    }
    return "-";
  }*/
}

/*import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../data/models/gym_info_model.dart';
import '../data/repositories/gym_Info_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/text_repository.dart';
import '../utils/distance_calculator.dart';

class GymDetailViewModel extends ChangeNotifier {
  final GymInfoRepository _gymInfoRepository = GymInfoRepository();
  final UserRepository _userRepository = UserRepository();

  GymInfo? _gymInfo;
  bool _isLoading = true;
  double? _distanceFromUser;
  bool _isDistanceLoading = true;
  List<Map<String, dynamic>> _gymRules = [];
  bool _isLiked = false;


  GymInfo? get gymInfo => _gymInfo;

  String get gymName => _gymInfo?.name ?? '';

  bool get isLoading => _isLoading;

  bool get isDistanceLoading => _isDistanceLoading;

  String get formattedDistance {
    if (_isDistanceLoading) return "거리 계산 중...";
    if (_distanceFromUser != null) {
      return '현위치로부터 ${_distanceFromUser!.toStringAsFixed(2)} km';
    }
    return "-";
  }

  List<Map<String, dynamic>> get gymRules => _gymRules;

  bool get isLiked => _isLiked;

  /// 체육관 정보를 가져오는 메서드
  Future<void> fetchGymDetail(String gymId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 체육관 정보와 좋아요한 체육관 ID 리스트를 동시에 가져옴
      final gymFuture = _gymInfoRepository.getGymById(gymId);
      final likedGymsFuture = _userRepository.getLikedGymIds();
      final results = await Future.wait([gymFuture, likedGymsFuture]);

      _gymInfo = results[0] as GymInfo;
      final likedGyms = results[1] as List<String>;
      _isLiked = likedGyms.contains(_gymInfo!.name);
    } catch (e) {
      print("Error fetching gym detail: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      await loadGymRulesJson();
      _calculateDistance();
    }
  }

  /// 위치 기반 거리 계산
  Future<void> _calculateDistance() async {
    try {
      _isDistanceLoading = true;
      notifyListeners();

      if (_gymInfo?.coord != null) {
        final location = Location();
        final userLocation = await location.getLocation();
        _distanceFromUser = DistanceCalculator.calculateKm(
          startLat: userLocation.latitude!,
          startLng: userLocation.longitude!,
          endLat: _gymInfo!.coord.latitude,
          endLng: _gymInfo!.coord.longitude,
        );
      }
    } catch (e) {
      print("Error calculating distance: $e");
    } finally {
      _isDistanceLoading = false;
      notifyListeners();
    }
  }

  /// 좋아요 상태 토글 함수
  Future<void> toggleFavoriteGym(String gymId) async {
    final previousState = _isLiked;
    _isLiked = !_isLiked;
    notifyListeners();

    try {
      await _userRepository.toggleLikedGym(gymId);
    } catch (e) {
      print("Error toggling favorite: $e");
      _isLiked = previousState;
      notifyListeners();
    }
  }

  /// 체육관 규칙 텍스트 파일을 로드
  Future<void> loadGymRulesJson() async {
    try {
      _gymRules = await TextRepository().loadJsonListFromLocal(
          'assets/text/gym_rules.json');
      notifyListeners();
      print("gymRules: $_gymRules");
    } catch (e) {
      print("Error loading JSON: $e");
    }
  }
}*/
