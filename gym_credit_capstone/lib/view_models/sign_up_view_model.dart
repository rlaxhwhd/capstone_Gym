import 'package:gym_credit_capstone/data/repositories/auth_repository.dart';
import 'package:gym_credit_capstone/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';

import 'package:gym_credit_capstone/data/models/sign_up_model.dart';

// ============================================================================
// 열거형 및 상수
// ============================================================================

enum SignUpStep {
  agreement,
  telVerification,
  signUpInfo,
  idPassword,
  finalResult
}

class SignUpViewModel extends ChangeNotifier {
  // ============================================================================
  // 상수 정의
  // ============================================================================

  static const int totalSteps = 5;
  static const pageAnimationDuration = Duration(milliseconds: 300);
  static const pageAnimationCurve = Curves.ease;

  // ============================================================================
  // 저장소 및 데이터 모델
  // ============================================================================

  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  final SignUpModel _signUpData = SignUpModel();

  // ============================================================================
  // 페이지 네비게이션 상태
  // ============================================================================

  int _currentPageIndex = SignUpStep.agreement.index;
  final PageController pageController = PageController();
  // ============================================================================
  // 폼 키 (지연 초기화로 GlobalKey 중복 방지)
  // ============================================================================

  late final List<GlobalKey<FormState>> formKeys;

  // ============================================================================
  // 1단계: 약관 동의 상태
  // ============================================================================

  bool agreedToTerms = false;
  bool agreedToPrivacyPolicy = false;
  bool agreedToPayment = false;

  // ============================================================================
  // 2-3단계: 사용자 입력 컨트롤러 및 데이터
  // ============================================================================

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isTelVerified = false;
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();
  bool _isRegistered = false;
  bool get isRegistered => _isRegistered;

  // ============================================================================
  // UserInfoStep 관련 상태 (새로 추가)
  // ============================================================================

  bool _isNicknameVerified = false;
  bool _isCheckingNickname = false;

  // 각 필드의 에러 메시지를 저장할 Map
  Map<String, String?> _userInfoFieldErrors = {
    'nickname': null,
    'birth': null,
    'streetAddress': null,
    'detailAddress': null,
  };

  // ============================================================================
  // 2-3단계: 페이지 완료 변수, 메서드
  // ============================================================================

  bool _isUserInfoCompleted = false;
  bool _isIdPasswordCompleted = false;

  bool get isUserInfoCompleted => _isUserInfoCompleted;
  bool get isIdPasswordCompleted => _isIdPasswordCompleted;

  void setUserInfoCompleted(bool value) {
    _isUserInfoCompleted = value;
    notifyListeners();
  }

  void setIdPasswordCompleted(bool value) {
    _isIdPasswordCompleted = value;
    notifyListeners();
  }

  // ============================================================================
  // UserInfoStep Getters (새로 추가)
  // ============================================================================

  bool get isNicknameVerified => _isNicknameVerified;
  bool get isCheckingNickname => _isCheckingNickname;
  Map<String, String?> get userInfoFieldErrors => Map.unmodifiable(_userInfoFieldErrors);

  // SignUpViewModel.dart에 추가할 코드들

  // ============================================================================
  // IdPasswordStep 관련 상태 (새로 추가)
  // ============================================================================

  bool _isEmailVerified = false;
  bool _isCheckingEmail = false;

  // 각 필드의 에러 메시지를 저장할 Map
  Map<String, String?> _idPasswordFieldErrors = {
    'email': null,
    'password': null,
    'passwordConfirm': null,
  };

  // ============================================================================
  // IdPasswordStep Getters (새로 추가)
  // ============================================================================

  bool get isEmailVerified => _isEmailVerified;
  bool get isCheckingEmail => _isCheckingEmail;
  Map<String, String?> get idPasswordFieldErrors => Map.unmodifiable(_idPasswordFieldErrors);

  // ============================================================================
  // IdPasswordStep 관련 메서드 (새로 추가)
  // ============================================================================

  /// 에러 메시지 업데이트
  void updateIdPasswordFieldError(String fieldKey, String? errorMessage) {
    _idPasswordFieldErrors[fieldKey] = errorMessage;
    _updateIdPasswordCompletionStatus();
    notifyListeners();
  }

  /// 필드별 유효성 검사
  void validateIdPasswordField(String fieldKey, String value) {
    String? errorMessage;

    switch (fieldKey) {
      case 'email':
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
        break;

      case 'password':
        if (value.trim().isEmpty) {
          errorMessage = '비밀번호를 입력해주세요';
        } else if (!isPasswordValid(value)) {
          errorMessage = '비밀번호 규칙을 지켜주세요 (8자 이상, 대소문자+숫자+특수문자)';
        }
        // 비밀번호가 변경되면 비밀번호 확인도 다시 검증
        if (_confirmPasswordController.text.isNotEmpty) {
          validateIdPasswordField('passwordConfirm', _confirmPasswordController.text);
        }
        break;

      case 'passwordConfirm':
        if (value.trim().isEmpty) {
          errorMessage = '비밀번호 확인을 입력해주세요';
        } else if (value != _passwordController.text) {
          errorMessage = '비밀번호가 일치하지 않습니다';
        }
        break;
    }

    updateIdPasswordFieldError(fieldKey, errorMessage);
  }

  /// 필드 검증과 완료 상태 업데이트를 함께 처리
  void validateIdPasswordFieldAndUpdate(String fieldKey, String value) {
    validateIdPasswordField(fieldKey, value);
  }

  /// 모든 필드가 완전히 채워졌는지 확인
  bool _areAllIdPasswordFieldsCompletelyFilled() {
    // 각 필드의 채워짐 여부 확인
    bool isEmailFilled = _emailController.text.trim().isNotEmpty;
    bool isPasswordFilled = _passwordController.text.trim().isNotEmpty;
    bool isPasswordConfirmFilled = _confirmPasswordController.text.trim().isNotEmpty;

    // 각 필드의 에러 상태 확인
    String? emailError = _idPasswordFieldErrors['email'];
    String? passwordError = _idPasswordFieldErrors['password'];
    String? passwordConfirmError = _idPasswordFieldErrors['passwordConfirm'];

    bool isEmailErrorNull = emailError == null;
    bool isPasswordErrorNull = passwordError == null;
    bool isPasswordConfirmErrorNull = passwordConfirmError == null;

    bool result = isEmailFilled &&
        isPasswordFilled &&
        isPasswordConfirmFilled &&
        isEmailErrorNull &&
        isPasswordErrorNull &&
        isPasswordConfirmErrorNull &&
        _isEmailVerified;

    print("IdPassword 완료 상태 체크: $result");
    print("IdPassword 에러 상태 (종합): $_idPasswordFieldErrors");
    print('--- IdPassword 상세 체크 종료 ---');
    return result;
  }

  /// 완료 상태 업데이트
  void _updateIdPasswordCompletionStatus() {
    final isCompleted = _areAllIdPasswordFieldsCompletelyFilled();
    if (_isIdPasswordCompleted != isCompleted) {
      _isIdPasswordCompleted = isCompleted;
      // notifyListeners()는 updateIdPasswordFieldError에서 호출되므로 여기서는 생략
    }
  }

  /// 이메일 중복 확인
  Future<void> checkEmailDuplicateAndUpdate() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      updateIdPasswordFieldError('email', '이메일을 입력해주세요');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      updateIdPasswordFieldError('email', '올바른 이메일 형식이 아닙니다');
      return;
    }

    _isCheckingEmail = true;
    notifyListeners();

    try {
      bool result = await checkEmailDuplicate(email);
      _isEmailVerified = result;
      updateIdPasswordFieldError('email', result ? null : '중복된 이메일입니다');
    } finally {
      _isCheckingEmail = false;
      notifyListeners();
    }
  }

  /// 비밀번호 유효성 검사 헬퍼 메서드
  bool isPasswordValid(String password) {
    // 8자 이상, 대소문자+숫자+특수문자 포함
    if (password.length < 8) return false;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[!@#\$%^&*]'));

    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }

  // ============================================================================
  // 로딩 및 에러 상태
  // ============================================================================

  bool _isLoading = false;
  String? _errorMessage;

  bool get isTelVerified => isTelFormatValid(phoneNumberController.text);

  void valuableState(){
    bool hi = agreedToTerms && agreedToPrivacyPolicy && agreedToPayment;
    print("이메일 변수: ${_emailController.text}");
    print("약관동의 함수 변수: $hi");
    print("전화번호 유효성검사: ${isTelVerified}");
    print("비밀번호 변수: ${_passwordController.text}");
    print("비밀번호 확인 변수: ${_confirmPasswordController.text}");
    print("닉네임 변수: ${_nicknameController.text}");
    print("전화번호 변수: ${_phoneNumberController.text}");
    print("생년월일 변수: ${_birthController.text}");
    print("도로명 주소 변수: ${_streetAddressController.text}");
    print("상세 주소 변수: ${_detailAddressController.text}");
    print("회원가입 여부 변수: $_isRegistered");
  }

  // ============================================================================
  // 생성자 (GlobalKey 초기화)
  // ============================================================================

  SignUpViewModel() {
    formKeys = List.generate(totalSteps, (_) => GlobalKey<FormState>());
  }

  // ============================================================================
  // Getter - 네비게이션
  // ============================================================================

  int get currentPageIndex => _currentPageIndex;
  SignUpStep get currentStep => SignUpStep.values[_currentPageIndex];

  // ============================================================================
  // Getter - 컨트롤러
  // ============================================================================

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController => _confirmPasswordController;
  TextEditingController get nicknameController => _nicknameController;
  TextEditingController get phoneNumberController => _phoneNumberController;
  TextEditingController get birthController => _birthController;
  TextEditingController get streetAddressController => _streetAddressController;
  TextEditingController get detailAddressController => _detailAddressController;

  // ============================================================================
  // Getter - 상태
  // ============================================================================

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isRequiredAgreed => agreedToTerms && agreedToPrivacyPolicy && agreedToPayment;

  // ============================================================================
  // 약관 동의 관련 메서드
  // ============================================================================

  void setAgreement({
    bool? terms,
    bool? privacy,
    bool? payment,
  }) {
    if (terms != null) agreedToTerms = terms;
    if (privacy != null) agreedToPrivacyPolicy = privacy;
    if (payment != null) agreedToPayment = payment;
    notifyListeners();
  }

  void setAllAgreements(bool value) {
    agreedToTerms = value;
    agreedToPrivacyPolicy = value;
    agreedToPayment = value;
    notifyListeners();
  }

  // ============================================================================
  // 전화번호 인증 관련 메서드
  // ============================================================================

  /// 전화번호 인증이 완료되었을 때 호출하는 메서드
  void setVerifiedPhoneNumber(String phoneNumber, bool isPhoneNumberVerified) {
    _phoneNumberController.text = phoneNumber;
    _isTelVerified = isPhoneNumberVerified;

    print('전화번호 인증 완료: $phoneNumber');
    notifyListeners(); // UI 업데이트를 위해 필수!
  }

  // ============================================================================
  // UserInfoStep 관련 메서드 (새로 추가)
  // ============================================================================

  /// 에러 메시지 업데이트
  void updateUserInfoFieldError(String fieldKey, String? errorMessage) {
    _userInfoFieldErrors[fieldKey] = errorMessage;
    _updateUserInfoCompletionStatus();
    notifyListeners();
  }

  /// 필드별 유효성 검사
  void validateUserInfoField(String fieldKey, String value) {
    String? errorMessage;

    switch (fieldKey) {
      case 'nickname':
        if (value.trim().isEmpty) {
          errorMessage = '닉네임을 입력해주세요';
          if (_isNicknameVerified) {
            _isNicknameVerified = false;
          }
        } else if (_isNicknameVerified) {
          // 닉네임이 변경되면 검증 상태 초기화
          _isNicknameVerified = false;
        }
        break;

      case 'birth':
        if (value.trim().isEmpty) {
          errorMessage = '생년월일을 입력해주세요';
        }
        break;

      case 'streetAddress':
        if (value.trim().isEmpty) {
          errorMessage = '도로명주소를 입력해주세요';
        }
        break;

      case 'detailAddress':
        if (value.trim().isEmpty) {
          errorMessage = '상세주소를 입력해주세요';
        }
        break;
    }

    updateUserInfoFieldError(fieldKey, errorMessage);
  }

  /// 필드 검증과 완료 상태 업데이트를 함께 처리
  void validateUserInfoFieldAndUpdate(String fieldKey, String value) {
    validateUserInfoField(fieldKey, value);
  }

  /// 모든 필드가 완전히 채워졌는지 확인
  bool _areAllUserInfoFieldsCompletelyFilled() {
    // 각 필드의 채워짐 여부 확인
    bool isNicknameFilled = _nicknameController.text.trim().isNotEmpty;
    bool isBirthFilled = _birthController.text.trim().isNotEmpty;
    bool isStreetAddressFilled = _streetAddressController.text.trim().isNotEmpty;
    bool isDetailAddressFilled = _detailAddressController.text.trim().isNotEmpty;

    // 각 필드의 에러 상태 확인
    String? nicknameError = _userInfoFieldErrors['nickname'];
    String? birthError = _userInfoFieldErrors['birth'];
    String? streetAddressError = _userInfoFieldErrors['streetAddress'];
    String? detailAddressError = _userInfoFieldErrors['detailAddress'];

    bool isNicknameErrorNull = nicknameError == null;
    bool isBirthErrorNull = birthError == null;
    bool isStreetAddressErrorNull = streetAddressError == null;
    bool isDetailAddressErrorNull = detailAddressError == null;

    bool result = isNicknameFilled &&
        isBirthFilled &&
        isStreetAddressFilled &&
        isDetailAddressFilled &&
        isNicknameErrorNull &&
        isBirthErrorNull &&
        isStreetAddressErrorNull &&
        isDetailAddressErrorNull &&
        _isNicknameVerified;

    print("완료 상태 체크: $result");
    print("에러 상태 (종합): $_userInfoFieldErrors");
    print('--- 상세 체크 종료 ---');
    return result;
  }

  /// 완료 상태 업데이트
  void _updateUserInfoCompletionStatus() {
    final isCompleted = _areAllUserInfoFieldsCompletelyFilled();
    if (_isUserInfoCompleted != isCompleted) {
      _isUserInfoCompleted = isCompleted;
      // notifyListeners()는 updateUserInfoFieldError에서 호출되므로 여기서는 생략
    }
  }

  /// 닉네임 중복 확인
  Future<void> checkNicknameDuplicateAndUpdate() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      updateUserInfoFieldError('nickname', '닉네임을 입력해주세요');
      return;
    }

    _isCheckingNickname = true;
    notifyListeners();

    try {
      bool result = await checkNicknameDuplicate(nickname);
      _isNicknameVerified = result;
      updateUserInfoFieldError('nickname', result ? null : '중복된 닉네임입니다');
    } finally {
      _isCheckingNickname = false;
      notifyListeners();
    }
  }

  /// 주소 설정 (주소 검색 후 호출)
  void setStreetAddress(String address) {
    _streetAddressController.text = address;
    print('선택된 주소: $address');
    validateUserInfoFieldAndUpdate('streetAddress', address);
  }

  // ============================================================================
  // 유효성 검사 메서드
  // ============================================================================

  Future<bool> checkEmailDuplicate(String value) async {
    if (value.isEmpty) {
      return false;
    }
    UserRepository userRepository = UserRepository();
    bool isEmailDuplicate = await userRepository.checkUserExists(value);
    print("이메일 중복 체크!: $isEmailDuplicate");
    if (isEmailDuplicate == false) {
      return true;
    }
    return false;
  }

  Future<bool> checkNicknameDuplicate(String value) async {
    if (value.isEmpty) {
      return false;
    }
    UserRepository userRepository = UserRepository();
    bool isNicknameDuplicate = await userRepository.checkNicknameExists(value);
    print("닉네임 중복 체크!: $isNicknameDuplicate");
    if (isNicknameDuplicate == false) {
      return true;
    }
    return false;
  }

  bool isTelFormatValid(String value) {
    final RegExp phoneRegex = RegExp(r'^\d{3}-\d{4}-\d{4}$');

    if (phoneRegex.hasMatch(value)) {
      print('올바른 형식입니다.');
      return true;
    }
    return false;
  }
// ============================================================================
  // 네비게이션 메서드
  // ============================================================================

  Future<void> nextPage() async {
    print('[PAGE_NAVIGATION_LOG] nextPage() 호출 - 현재 페이지: $_currentPageIndex (${currentStep.name})');

    _errorMessage = null; // 에러 메시지 초기화

    // 현재 단계 유효성 검사
    bool canProceed = true;
    switch (currentStep) {
      case SignUpStep.agreement:
        if (!isRequiredAgreed) {
          _errorMessage = '필수 약관에 모두 동의해주세요.';
          canProceed = false;
        }
        break;
      case SignUpStep.telVerification: //전화번호 인증
        if (phoneNumberController.text.isEmpty) {
          _errorMessage = '인증을 완료해주세요.';
          canProceed = false;
        }
        break;
      case SignUpStep.signUpInfo: // 예: 전화번호, 생일, 주소
        final isValid = formKeys[_currentPageIndex].currentState?.validate() ?? false;
        if (!isValid) {
          _errorMessage = '입력값을 확인해주세요.';
          canProceed = false;
        }
        break;
      case SignUpStep.idPassword:
        print('[PAGE_NAVIGATION_LOG] idPassword 페이지 유효성 검사 시작');
        final isValid = formKeys[_currentPageIndex].currentState?.validate() ?? false;
        if (!isValid) {
          _errorMessage = '아이디와 비밀번호를 확인해주세요.';
          canProceed = false;
          print('[PAGE_NAVIGATION_LOG] idPassword 페이지 유효성 검사 실패: $_errorMessage');
        } else {
          print('[PAGE_NAVIGATION_LOG] idPassword 페이지 유효성 검사 성공');
        }
        break;

      case SignUpStep.finalResult:
        print('[PAGE_NAVIGATION_LOG] finalResult 페이지 - 추가 검사 없음');
        break;
    }

    if (!canProceed) {
      print('[PAGE_NAVIGATION_LOG] 다음 페이지 이동 불가 - 에러: $_errorMessage');
      notifyListeners(); // 에러 메시지 표시 등을 위해 UI 업데이트 알림
      return;
    }

    // 다음 단계로 이동 또는 제출
    if (_currentPageIndex < totalSteps - 1) {
      print('[PAGE_NAVIGATION_LOG] 페이지 이동 시작: $_currentPageIndex -> ${_currentPageIndex + 1}');
      _currentPageIndex++;
      await pageController.animateToPage(
        _currentPageIndex,
        duration: pageAnimationDuration,
        curve: pageAnimationCurve,
      );
      print('[PAGE_NAVIGATION_LOG] 페이지 이동 완료: 현재 페이지 $_currentPageIndex (${currentStep.name})');
      notifyListeners();
    }
  }

  void previousPage(BuildContext context) {
    print('[PAGE_NAVIGATION_LOG] previousPage() 호출 - 현재 페이지: $_currentPageIndex (${currentStep.name})');

    _errorMessage = null; // 에러 메시지 초기화

    if (_currentPageIndex > 0) {
      print('[PAGE_NAVIGATION_LOG] 이전 페이지로 이동: $_currentPageIndex -> ${_currentPageIndex - 1}');
      _currentPageIndex--;

      pageController.animateToPage(
        _currentPageIndex,
        duration: pageAnimationDuration,
        curve: pageAnimationCurve,
      );
      print('[PAGE_NAVIGATION_LOG] 이전 페이지 이동 완료: 현재 페이지 $_currentPageIndex (${currentStep.name})');
      notifyListeners();
    } else {
      // 첫 페이지에서 뒤로가기 시 - 앱 종료 허용
      print('[PAGE_NAVIGATION_LOG] 첫 페이지에서 뒤로가기 - 앱 종료 허용');
      Navigator.of(context).pop();
      notifyListeners(); // UI에 라우트 종료 필요 상태 알림
    }
  }
// ============================================================================
  // 이동 이동 버튼 관련 메서드
  // ============================================================================

  // 버튼에 표시될 텍스트를 반환하는 getter
  String get primaryButtonText {
    // 마지막 이전 스텝(회원가입 누르기 직전)인 경우
    if (currentPageIndex == totalSteps - 2) {
      return '회원가입';
    }
    if (currentPageIndex == 4) {
      return isRegistered ? '로그인 하러가기' : '이전 화면으로';
    }
    // 그 외 나머지 일반 스텝에서는 '다음'
    return '다음';
  }

  /// 버튼 눌렀을 때 실행할 콜백
  VoidCallback? buttonAction(BuildContext context) {
    print('[PAGE_NAVIGATION_LOG] buttonAction() 호출됨 - 현재 페이지: $_currentPageIndex (${currentStep.name})');

    if (isLoading) {
      print('[PAGE_NAVIGATION_LOG] 로딩 중이므로 버튼 액션 비활성화');
      return null;
    }
    valuableState();

    bool isAgreementChecked = agreedToTerms && agreedToPrivacyPolicy && agreedToPayment;

    if(currentPageIndex == 0 && !isAgreementChecked){
      print('[PAGE_NAVIGATION_LOG] 약관 동의 미완료로 버튼 비활성화');
      return null;
    }else if(currentPageIndex == 1 && !isTelVerified){
      print('[PAGE_NAVIGATION_LOG] 전화번호 인증 미완료로 버튼 비활성화');
      return null;
    }else if(currentPageIndex == 2 && !isUserInfoCompleted){
      print('[PAGE_NAVIGATION_LOG] 사용자 정보 입력 미완료로 버튼 비활성화');
      return null;
    }else if(currentPageIndex == 3 && !isIdPasswordCompleted){
      print('[PAGE_NAVIGATION_LOG] 아이디/비밀번호 입력 미완료로 버튼 비활성화');
      return null;
    }

    if(currentPageIndex == 3){
      return () async{

        print('[PAGE_NAVIGATION_LOG] submitSignUp() 완료 후 - _currentPageIndex: $_currentPageIndex, _isRegistered: $_isRegistered');
        print('[PAGE_NAVIGATION_LOG] 페이지 이동 시작 - current: $_currentPageIndex -> target: 4');

        nextPage();

        print('[PAGE_NAVIGATION_LOG] 페이지 이동 완료 - 최종 _currentPageIndex: $_currentPageIndex');

        print('[PAGE_NAVIGATION_LOG] 회원가입 버튼 클릭 - submitSignUp() 호출 전');
        print('[PAGE_NAVIGATION_LOG] 호출 전 현재 상태 - _currentPageIndex: $_currentPageIndex, _isLoading: $_isLoading');
        await submitSignUp();
        print('[PAGE_NAVIGATION_LOG] submitSignUp() 완료 후 - _currentPageIndex: $_currentPageIndex, _isRegistered: $_isRegistered');
        print('[PAGE_NAVIGATION_LOG] 페이지 이동 시작 - current: $_currentPageIndex -> target: 4');

        notifyListeners();
        print('[PAGE_NAVIGATION_LOG] 최종 notifyListeners() 호출 완료');
      };
    }

    if (currentPageIndex == 4) {
      print('[PAGE_NAVIGATION_LOG] 마지막 페이지 액션 - 가입 상태: $_isRegistered');
      return _isRegistered
          ? () {
        print('[PAGE_NAVIGATION_LOG] 가입 완료 - 화면 닫기');
        Navigator.of(context).pop({});
      }
          : () {
        print('[PAGE_NAVIGATION_LOG] 가입 미완료 - 이전 페이지로');
        previousPage(context);
      };
    }

    print('[PAGE_NAVIGATION_LOG] 일반 다음 페이지 이동 액션 반환');
    return () => nextPage(); // 그 외 페이지에서는 다음 페이지로
  }

  // ============================================================================
  // 제출 관련 메서드
  // ============================================================================

  Future<bool> submitSignUp() async {
    print('[PAGE_NAVIGATION_LOG] submitSignUp() 시작 - 현재 페이지: $_currentPageIndex');

    // 현재 페이지 인덱스 저장
    int tempPageIndex = _currentPageIndex;
    print('[PAGE_NAVIGATION_LOG] 임시 페이지 인덱스 저장: $tempPageIndex');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    print('[PAGE_NAVIGATION_LOG] 로딩 상태 설정 완료, notifyListeners() 호출됨');

    // 컨트롤러 값들을 데이터 모델에 업데이트
    _signUpData.nickName = _nicknameController.text;
    _signUpData.phoneNumber = _phoneNumberController.text;
    _signUpData.birthDate = _birthController.text;
    _signUpData.address = [_streetAddressController.text, _detailAddressController.text].where((s) => s.isNotEmpty).join(' ');
    _signUpData.agreeToTerms = agreedToTerms;
    _signUpData.agreeToPrivacy = agreedToPrivacyPolicy;
    _signUpData.agreeToPayment = agreedToPayment;

    try {
      // --- 실제 서버 제출 로직 ---
      print('회원가입 데이터 준비 완료:');
      print('아이디: ${_emailController.text}');
      print('닉네임: ${_signUpData.nickName}');
      print('전화번호: ${_signUpData.phoneNumber}');
      print('생일: ${_signUpData.birthDate}');
      print('주소: ${_signUpData.address}');

      try {
        print("[PAGE_NAVIGATION_LOG] 회원가입 시작");
        print('[PAGE_NAVIGATION_LOG] PageController 상태 - hasClients: ${pageController.hasClients}');

        print('[PAGE_NAVIGATION_LOG] createUserWithEmailAndPassword 호출 전');
        final credential = await _authRepository.signUp(_emailController.text.trim(), _passwordController.text);
        print('[PAGE_NAVIGATION_LOG] createUserWithEmailAndPassword 호출 후 - hasClients: ${pageController.hasClients}');

        if(credential?.user != null){
          try {
            print("[PAGE_NAVIGATION_LOG] saveUserData 호출 전 - hasClients: ${pageController.hasClients}");
            await _authRepository.saveUserData(
                credential!.user!.uid, _emailController.text.trim());
            print("[PAGE_NAVIGATION_LOG] saveUserData 호출 후 - hasClients: ${pageController.hasClients}");
            print("[PAGE_NAVIGATION_LOG] 회원가입 1차 성공");
          } catch(e){
            rethrow;
          }
        }
      } catch (e) {
        print('회원가입 계정 생성 실패: $e');
        // 에러시에도 페이지 복원
        _restorePageIndex(tempPageIndex);
        rethrow;
      }

      try {
        await _userRepository.updateUserByEmail(_emailController.text, _signUpData.toUserModel());
        print("[PAGE_NAVIGATION_LOG] 유저정보 업데이트");
        print('[PAGE_NAVIGATION_LOG] PageController 상태 - hasClients: ${pageController.hasClients},');
      } catch (e) {
        print('회원정보 업데이트 실패: $e');
        // 에러시에도 페이지 복원
        _restorePageIndex(tempPageIndex);
        rethrow;
      }

      print('[PAGE_NAVIGATION_LOG] 회원가입 전체 성공!');
      print('[PAGE_NAVIGATION_LOG] PageController 상태 - hasClients: ${pageController.hasClients},');
      _isRegistered = true;
      print('[PAGE_NAVIGATION_LOG] PageController 상태 - hasClients: ${pageController.hasClients},');
      _isLoading = false;
      print('[PAGE_NAVIGATION_LOG] _isRegistered = true, _isLoading = false 설정');
      print('[PAGE_NAVIGATION_LOG] PageController 상태 - hasClients: ${pageController.hasClients}, ');
      notifyListeners();

      // 성공 후 페이지 복원
      _restorePageIndex(tempPageIndex);

      print('[PAGE_NAVIGATION_LOG] submitSignUp() 완료 직전 notifyListeners() 호출');
      print('[PAGE_NAVIGATION_LOG] PageController 상태 - hasClients: ${pageController.hasClients}, ');
      return true;

    } catch (e) {
      // 에러 처리
      _errorMessage = '회원가입 중 오류가 발생했습니다: $e';
      print('회원가입 실패: $e');
      _isLoading = false;
      notifyListeners();
      return false;
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
  // ============================================================================
  // 리소스 정리
  // ============================================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    _phoneNumberController.dispose(); // 추가된 컨트롤러도 dispose
    _birthController.dispose();
    _streetAddressController.dispose();
    _detailAddressController.dispose();
    pageController.dispose();
    super.dispose();
  }
}