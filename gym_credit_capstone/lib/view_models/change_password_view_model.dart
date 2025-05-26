import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final TextEditingController currentPasswordController = TextEditingController();

  bool _obscureText = true;
  bool get obscureText => _obscureText;

  bool _isInputValid = false;
  bool get isInputValid => _isInputValid;

  ChangePasswordViewModel() {
    currentPasswordController.addListener(_checkInput);
  }

  void _checkInput() {
    _isInputValid = currentPasswordController.text.isNotEmpty;
    notifyListeners();
  }
  bool _showError = false;
  bool get showError => _showError;

  void togglePasswordVisibility() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  Future<bool> verifyPasswordWithFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPasswordController.text,
      );

      // Firebase에 비밀번호 재인증 시도
      await user.reauthenticateWithCredential(credential);

      _showError = false;
      notifyListeners();
      return true;
    } catch (e) {
      _showError = true;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    super.dispose();
  }
}
