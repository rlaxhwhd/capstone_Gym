import 'package:gym_credit_capstone/data/repositories/auth_repository.dart';
import 'package:gym_credit_capstone/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';

enum FindPasswordStep {
  emailCheck,
  finalResult
}

class FindPasswordViewModel extends ChangeNotifier {
  static const int totalSteps = 2;
  static const pageAnimationDuration = Duration(milliseconds: 300);
  static const pageAnimationCurve = Curves.ease;

  final _repository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _currentPageIndex = FindPasswordStep.emailCheck.index;
  final PageController pageController = PageController();

  int get currentPageIndex => _currentPageIndex;
  FindPasswordStep get currentStep => FindPasswordStep.values[_currentPageIndex];

  // ============================================================================
  // 이메일 관련 상태 및 컨트롤러
  // ============================================================================

  final TextEditingController _emailController = TextEditingController();

  bool _isEmailVerified = false;
  bool _isCheckingEmail = false;

  // 필드의 에러 메시지를 저장할 Map
  Map<String, String?> _fieldErrors = {
    'email': null,
  };

  // ============================================================================
  // Getters
  // ============================================================================

  TextEditingController get emailController => _emailController;

  bool get isEmailVerified => _isEmailVerified;
  bool get isCheckingEmail => _isCheckingEmail;
  Map<String, String?> get fieldErrors => Map.unmodifiable(_fieldErrors);

  // ============================================================================
  // 유효성 검사 메서드
  // ============================================================================

  /// 에러 메시지 업데이트
  void updateFieldError(String fieldKey, String? errorMessage) {
    _fieldErrors[fieldKey] = errorMessage;
    notifyListeners();
  }

  /// 필드 유효성 검사
  void validateFieldAndUpdate(String fieldKey, String value) {
    String? errorMessage;

    if (fieldKey == 'email') {
      if (value.trim().isEmpty) {
        errorMessage = '이메일을 입력해주세요';
        if (_isEmailVerified) {
          _isEmailVerified = false;
        }
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        errorMessage = '올바른 이메일 형식이 아닙니다';
        if (_isEmailVerified) {
          _isEmailVerified = false;
        }
      } else if (_isEmailVerified) {
        // 이메일이 변경되면 검증 상태 초기화
        _isEmailVerified = false;
      }
    }

    updateFieldError(fieldKey, errorMessage);
  }

  // ============================================================================
  // 이메일 관련 메서드
  // ============================================================================

  /// 이메일 존재 여부 확인 (비밀번호 찾기용 - 회원가입과 반대 로직)
  Future<void> checkEmailDuplicateAndUpdate() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      updateFieldError('email', '이메일을 입력해주세요');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      updateFieldError('email', '올바른 이메일 형식이 아닙니다');
      return;
    }

    _isCheckingEmail = true;
    notifyListeners();

    try {
      // 비밀번호 찾기에서는 존재하는 이메일인지 확인해야 함 (회원가입과 반대)
      bool emailExists = await _userRepository.checkUserExists(email);
      _isEmailVerified = emailExists;
      updateFieldError('email', emailExists ? null : '등록되지 않은 이메일입니다');
    } finally {
      _isCheckingEmail = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // 단계별 완료 여부 확인
  // ============================================================================

  /// 이메일 검증 완료 여부 확인
  bool get isEmailStepCompleted {
    return _emailController.text.trim().isNotEmpty &&
        _fieldErrors['email'] == null &&
        _isEmailVerified;
  }

  // ============================================================================
  // 페이지 네비게이션 메서드들
  // ============================================================================

  Future<void> nextPage() async {
    if (_currentPageIndex < totalSteps - 1) {
      _currentPageIndex++;
      await pageController.animateToPage(
        _currentPageIndex,
        duration: pageAnimationDuration,
        curve: pageAnimationCurve,
      );
      notifyListeners();
    }
  }

  void previousPage(BuildContext context) {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      pageController.animateToPage(
        _currentPageIndex,
        duration: pageAnimationDuration,
        curve: pageAnimationCurve,
      );
      notifyListeners();
    } else {
      Navigator.of(context).pop();
      notifyListeners();
    }
  }

  void setPageIndex(int index) {
    if (index >= 0 && index < totalSteps) {
      _currentPageIndex = index;
      if (pageController.hasClients) {
        pageController.jumpToPage(index);
      }
      notifyListeners();
    }
  }

  // 버튼에 표시될 텍스트를 반환하는 getter
  String get primaryButtonText {
    // 첫 번째 스텝(이메일 확인)에서는 '비밀번호 재설정 이메일 발송'
    if (currentPageIndex == 0) {
      return '인증 메일 받기';
    }
    // 그 외는 '완료'
    return '로그인 화면으로';
  }

  /// 버튼 눌렀을 때 실행할 콜백
  VoidCallback? buttonAction(BuildContext context) {
    print('[PAGE_NAVIGATION_LOG] buttonAction() 호출됨 - 현재 페이지: $_currentPageIndex (${currentStep.name})');

    if (isLoading) {
      print('[PAGE_NAVIGATION_LOG] 로딩 중이므로 버튼 액션 비활성화');
      return null;
    }

    // 첫 번째 페이지(이메일 확인)에서는 이메일 검증 완료 여부 확인
    if (currentPageIndex == 0 && !isEmailStepCompleted) {
      print('[PAGE_NAVIGATION_LOG] 이메일 검증 미완료로 버튼 비활성화');
      return null;
    }

    // 이메일 확인 페이지에서 "비밀번호 재설정 이메일 발송" 버튼을 눌렀을 때
    if (currentPageIndex == 0)  {
      print('[PAGE_NAVIGATION_LOG] 비밀번호 재설정 이메일 발송 액션 실행');
      return () async{
        await nextPage();
        _executePasswordReset(context);
      };
    }

    print('[PAGE_NAVIGATION_LOG] 완료 액션 반환');
    return () => Navigator.of(context).pop(); // 마지막 페이지에서는 화면 종료
  }

  // ============================================================================
  // 비밀번호 재설정 이메일 발송 실행
  // ============================================================================

  /// 실제 비밀번호 재설정 이메일 발송 실행
  Future<void> _executePasswordReset(BuildContext context) async {
    if (!isEmailStepCompleted) {
      return;
    }
    int tempPageIndex = _currentPageIndex;
    _isLoading = true;
    notifyListeners();

    try {
      final email = _emailController.text.trim();

      String? errorMessage = await resetPassword(email);

      if (errorMessage == null) {
        // 성공 시 다음 페이지로

      } else {
        // 에러 처리
        print('[PASSWORD_RESET_ERROR] $errorMessage');
        // 필요시 스낵바나 다이얼로그로 에러 표시
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } finally {
      _isLoading = false;
      _restorePageIndex(tempPageIndex);
      notifyListeners();
    }
  }

  /// 비밀번호 재설정 이메일 발송 API 호출
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

  // 페이지 복원 헬퍼 메서드
  void _restorePageIndex(int targetPageIndex) {
    print('[PAGE_NAVIGATION_LOG] 페이지 복원 시도: $targetPageIndex');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        print('[PAGE_NAVIGATION_LOG] 페이지 복원 실행: $targetPageIndex');
        pageController.jumpToPage(targetPageIndex);
        _currentPageIndex = targetPageIndex;
      } else {
        print('[PAGE_NAVIGATION_LOG] PageController 연결되지 않음, 인덱스만 설정: $targetPageIndex');
        _currentPageIndex = targetPageIndex;
      }
    });
  }
  @override
  void dispose() {
    _emailController.dispose();
    pageController.dispose();
    super.dispose();
  }
}