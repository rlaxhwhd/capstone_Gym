import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  UserModel? _userModel;
  bool _isLoading = true;

  ProfileViewModel({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository() {
    fetchUserData();
  }

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final data = await _userRepository.getUserByEmail(user.email ?? '');
      _userModel = data;
    }
    _isLoading = false;
    notifyListeners();
  }
}
