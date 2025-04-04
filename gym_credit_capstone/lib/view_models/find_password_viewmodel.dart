import '../data/repositories/auth_repository.dart';

class FindPasswordViewModel {
  final AuthRepository _repository = AuthRepository();

  Future<String?> resetPassword(String email) async {
    if (email.isEmpty) {
      return '이메일을 입력해주세요.';
    }

    try {
      await _repository.sendPasswordResetEmail(email);
      return null; // 성공 메시지를 처리하지 않음 (성공)
    } catch (e) {
      return '오류 발생: ${e.toString()}';
    }
  }
}
