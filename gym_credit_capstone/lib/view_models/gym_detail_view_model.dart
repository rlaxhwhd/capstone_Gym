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
}