import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewPasswordViewModel extends ChangeNotifier {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool get obscureNewPassword => _obscureNewPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  bool get isFilled =>
      newPasswordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty;

  bool get isSame =>
      newPasswordController.text == confirmPasswordController.text;

  void toggleNewPasswordVisibility() {
    _obscureNewPassword = !_obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  Future<bool> updatePassword() async {
    try {
      if (!isSame) return false;

      final user = FirebaseAuth.instance.currentUser;
      await user?.updatePassword(newPasswordController.text);
      return true;
    } catch (e) {
      debugPrint('비밀번호 업데이트 실패: $e');
      return false;
    }
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
