import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  UserModel? _user;
  UserModel? get user => _user;

  final String appVersion = '25.0.0';

  Future<void> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userData = await _userRepository.getUserInfo(currentUser.uid, currentUser.email);
      _user = userData;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void goToDeleteAccount(BuildContext context) {
    Navigator.pushNamed(context, '/deleteAccount');
  }
}
