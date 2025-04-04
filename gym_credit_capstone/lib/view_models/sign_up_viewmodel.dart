import '../data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SignUpViewModel {
  final AuthRepository _repository = AuthRepository();

  Future<String?> signUp(String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      return '비밀번호가 일치하지 않습니다.';
    }

    try {
      final credential = await _repository.signUp(email, password);
      if (credential?.user != null) {
        await _repository.saveUserData(credential!.user!.uid, email);
        return null; // 성공 시 null 반환
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return '비밀번호가 너무 약합니다.';
      } else if (e.code == 'email-already-in-use') {
        return '이미 사용 중인 이메일입니다.';
      }
    } catch (e) {
      return '오류 발생: ${e.toString()}';
    }

    return '회원가입 실패';
  }
}
