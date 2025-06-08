import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:gym_credit_capstone/data/repositories/auth_repository.dart';
import 'package:gym_credit_capstone/data/repositories/api/api_repository.dart';
import 'package:gym_credit_capstone/utils/crypto_utils.dart';
import 'package:gym_credit_capstone/utils/device_fingerprint.dart';
import 'package:gym_credit_capstone/utils/challenge_generator.dart';

enum IdentityVerificationStep {
  selectCarrier,
  userInfo,
  smsVerification,
  finalResult
}

class IdentityVerificationViewModel extends ChangeNotifier{
  static const int totalSteps = 4;
  static const pageAnimationDuration = Duration(milliseconds: 300);
  static const pageAnimationCurve = Curves.ease;
  final String destinationEmail = dotenv.env['EMAIL'] ?? '';
  final List<String> carriers = ['SKT', 'KT', 'LG'];

  ApiRepository apiRepository = ApiRepository();

  // --- 상태 변수 ---
  int _currentPageIndex = IdentityVerificationStep.selectCarrier.index;
  int get currentPageIndex => _currentPageIndex;
  IdentityVerificationStep get currentStep => IdentityVerificationStep.values[_currentPageIndex];
  bool _isRestoring = false;
  bool get isRestoring => _isRestoring;

   PageController pageController = PageController();

  // Step 1: 통신사 선택
  String? selectedCarrier;
  String? get selectedCarrierName => selectedCarrier;

  // Step 2: 전화번호 입력
  final TextEditingController telController = TextEditingController();

  // Step 3: 추가 정보 입력
  bool _isVerified = false;
  bool get isVerified => _isVerified;
  bool _isSendClicked = false;

  // 각 단계별 Form Key
  final List<GlobalKey<FormState>> formKeys = List.generate(totalSteps, (_) => GlobalKey<FormState>());

  // 로딩 및 에러 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;


  // 코드변수
  String _fingerprint = '';
  String _challengePlain = '';
  String _hmac = '';
  String _timeStamp = '';

  bool _isTelStepCompleted = false;

  bool get isTelStepCompleted => isTelStepCompleted;

  void setTelStepCompleted(bool value) {
    _isTelStepCompleted = value;
    notifyListeners();
  }


  //전번 유효성 검사
  bool isValidPhoneNumber(String input) {
    // 숫자만 추출
    final digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');

    // 010, 011, 016, 017, 018, 019로 시작하고, 총 10자리 또는 11자리인지 확인
    final regExp = RegExp(r'^01[016789]\d{7,8}$');

    return regExp.hasMatch(digitsOnly);
  }






  // --- 메서드 ---

  void selectCarrier(String carrier) {
    if(carrier == 'LG U+'){
      carrier = 'LG';
    }
    selectedCarrier = carrier;
    notifyListeners();
  }

  Future<void> nextPage() async {
    print('📱 [PAGE_NAVIGATION] nextPage() 호출됨 - 현재 페이지: $_currentPageIndex (${currentStep.name})');

    _errorMessage = null; // 에러 메시지 초기화

    // 현재 단계 유효성 검사
    bool canProceed = true;
    switch (currentStep) {
      case IdentityVerificationStep.selectCarrier:
        if (selectedCarrier == null) {
          _errorMessage = '통신사를 선택해주세요';
          canProceed = false;
        }
        break;
      case IdentityVerificationStep.userInfo:
        if(telController.text.isEmpty){
          _errorMessage = '전화번호를 입력해주세요';
          canProceed = false;
        }else if(telController.text.length != 13){
          _errorMessage = '올바른 전화번호를 입력해주세요';
          canProceed = false;
        }
        break;
      case IdentityVerificationStep.smsVerification:
        if(!_isSendClicked){
          _errorMessage = '인증 메시지를 보내주세요';
          canProceed = false;
        }
        break;
      case IdentityVerificationStep.finalResult:
        break;
    }

    if (!canProceed) {
      print('❌ [PAGE_NAVIGATION] 유효성 검사 실패 - 페이지: $_currentPageIndex, 단계: ${currentStep.name}, 에러: $_errorMessage');
      notifyListeners(); // 에러 메시지 표시 등을 위해 UI 업데이트 알림
      return;
    }

    // 다음 단계로 이동
    if (_currentPageIndex < totalSteps - 1) {
      int targetPageIndex = _currentPageIndex + 1;
      print('📱 [PAGE_NAVIGATION] 페이지 이동 시도: $_currentPageIndex → $targetPageIndex');

      _currentPageIndex = targetPageIndex;

      await pageController.animateToPage(
        _currentPageIndex,
        duration: pageAnimationDuration,
        curve: pageAnimationCurve,
      );

      print('✅ [PAGE_NAVIGATION] 페이지 이동 완료: $_currentPageIndex (${currentStep.name})');
      notifyListeners();
    } else {
      print('🚫 [PAGE_NAVIGATION] 이미 마지막 페이지입니다: $_currentPageIndex');
    }
  }

  void previousPage(BuildContext context) {
    print('📱 [PAGE_NAVIGATION] previousPage() 호출됨 - 현재 페이지: $_currentPageIndex (${currentStep.name})');

    _errorMessage = null; // 에러 메시지 초기화

    if (_currentPageIndex > 0) {
      int targetPageIndex = _currentPageIndex - 1;
      print('📱 [PAGE_NAVIGATION] 이전 페이지로 이동: $_currentPageIndex → $targetPageIndex');

      _currentPageIndex = targetPageIndex;
      pageController.animateToPage(
        _currentPageIndex,
        duration: pageAnimationDuration,
        curve: pageAnimationCurve,
      );

      print('✅ [PAGE_NAVIGATION] 이전 페이지 이동 완료: $_currentPageIndex (${currentStep.name})');
      notifyListeners();
    } else {
      // 첫 페이지에서 뒤로가기 시
      print('🚪 [PAGE_NAVIGATION] 첫 페이지에서 뒤로가기 - 라우트 종료 설정');
      Navigator.of(context).pop();
      notifyListeners(); // UI에 라우트 종료 필요 상태 알림
    }
  }

  // updateCurrentPage 메서드 수정
  void updateCurrentPage(int index) {
    print('⚠️ [PAGE_NAVIGATION] updateCurrentPage() 호출됨 - 현재: $_currentPageIndex → 목표: $index');
    print('⚠️ [PAGE_NAVIGATION] 복원 모드: $_isRestoring');

    _currentPageIndex = index;

    // 복원 상황이 아닐 때만 페이지 상태 리셋
    if (!_isRestoring) {
      print('⚠️ [PAGE_NAVIGATION] 일반 페이지 이동, 상태 리셋 실행');
      resetPageState();
    } else {
      print('⚠️ [PAGE_NAVIGATION] 페이지 복원 중, 상태 리셋 스킵');
    }

    notifyListeners();
    print('⚠️ [PAGE_NAVIGATION] updateCurrentPage() 완료 - 현재 페이지: $_currentPageIndex (${currentStep.name})');
  }

  /// 버튼에 보여줄 텍스트
  String get buttonText {
    final last = totalSteps - 1;
    if (currentPageIndex == last - 1)     return '메시지 전송 완료';
    if (currentPageIndex == last)         return isVerified ? '회원가입으로 돌아가기' : '이전 화면';
    return '다음';
  }

  /// 버튼 눌렀을 때 실행할 콜백
  VoidCallback? buttonAction(BuildContext context) {
    print('🔘 [PAGE_NAVIGATION] buttonAction() 호출됨 - 현재 페이지: $_currentPageIndex (${currentStep.name})');

    if (isLoading) {
      print('⏳ [PAGE_NAVIGATION] 로딩 중이므로 버튼 액션 비활성화');
      return null;
    }

    if(currentPageIndex == 2 && telController.text == "777-7777-7777"){
      return () {
        print('✅ [PAGE_NAVIGATION] 가짜 인증 완료 - 화면 닫기');
        _isSendClicked = true;
        Navigator.of(context).pop({
          'phoneNumber': telController.text,
          'isVerified': true,
        });
      };
    }

    bool istelNotComplited = !isValidPhoneNumber(telController.text) && telController.text.trim().isEmpty;

    if(currentPageIndex == 0 && selectedCarrier == null){
      return null;
    }else if(currentPageIndex == 1 && !_isTelStepCompleted){
      return null;
    }else if(currentPageIndex == 2 && !_isSendClicked){
      return null;
    }



    final last = totalSteps - 1;

    // 마지막 페이지에서의 동작
    if (currentPageIndex == last) {
      print('🔘 [PAGE_NAVIGATION] 마지막 페이지 액션 - 인증 상태: $isVerified');
      return isVerified
          ? () {
        print('✅ [PAGE_NAVIGATION] 인증 완료 - 화면 닫기');
        Navigator.of(context).pop({
          'phoneNumber': telController.text,
          'isVerified': isVerified,
        });
      }
          : () {
        print('❌ [PAGE_NAVIGATION] 인증 미완료 - 이전 페이지로');
        _isSendClicked = false;
        previousPage(context);
      };
    }
    else if (currentPageIndex == last-1) {
      print('📱 [PAGE_NAVIGATION] SMS 인증 페이지 액션 - checkSms() 실행');
      return () async{
        print('🚀 [PAGE_NAVIGATION] SMS 인증 및 페이지 이동 시작');
        nextPage();
        await checkSms();
        notifyListeners();
        print('🚀 [PAGE_NAVIGATION] SMS 인증 및 페이지 이동 완료');
      };
    }

    print('🔘 [PAGE_NAVIGATION] 일반 다음 페이지 액션');
    return () => nextPage(); // 그 외 페이지에서는 다음 페이지로
  }

  Future<String> _generateVerifyCode(int method) async{
    _fingerprint = await generateDeviceFingerprint(AuthRepository());
    final (challengePlain,timeStamp) = await generateChallengePlain(_fingerprint);
    _challengePlain = challengePlain;
    _timeStamp = timeStamp;
    _hmac = await apiRepository.zeroKnowledgeHmac(_challengePlain);

    String returnCode = "$_fingerprint|$_challengePlain|$_hmac|$_timeStamp";
    print("일반 코드생성: ${returnCode}");
    return encodeString(returnCode);
  }

  // 코드 생성 및 sms 보내기
  Future<void> sendSms() async {
    String message = await _generateVerifyCode(0);
    final Uri smsUri = Uri.parse('sms:$destinationEmail?body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      _isSendClicked = true;
      _errorMessage = null; // 에러 메시지 초기화
      notifyListeners();
    } else {
      _errorMessage = 'SMS 앱을 열 수 없습니다';
      debugPrint('SMS 앱을 열 수 없습니다');
      notifyListeners();
    }
  }

  //메시지 검증
  Future<void> checkSms() async {
    print('🔍 [PAGE_NAVIGATION] checkSms() 시작 - 현재 페이지: $_currentPageIndex');
    int tempPageIndex = _currentPageIndex;

    _isLoading = true;
    notifyListeners();

    try {
      print("phoneNumberkk = ${telController.text}");
      final response =  await apiRepository.sendVerificationRequest(
        phoneNumber: telController.text.replaceAll('-', ''),
        carrier: selectedCarrier ?? '',
        fingerprint: _fingerprint,
        challengeCode: _challengePlain,
        hmac: _hmac,
        timeStamp: _timeStamp,
      );
      print("각 서버용 코드들 : $_fingerprint, $_challengePlain, $_hmac, $_timeStamp");

      if(response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['message'] == 'telephone_Verification_Success') {
          print('✅ [PAGE_NAVIGATION] 인증 성공!');
          _isVerified = true;
          notifyListeners();
        }
      }else if (response.statusCode == 400) {
        print("클라이언트 오류");
        throw Exception('Invalid request');
        // 예: TimeStamp 불일치, HMAC 불일치 등
      } else if (response.statusCode == 404) {
        print("이메일 없음");
        throw Exception('Email not found');
        // 예: 최근 5분 이내 이메일 없음
      } else if (response.statusCode == 500) {
        print("서버 에러");
        throw Exception('Internal server error');
        // 예: 서버 오류
      } else {
        print("알 수 없는 상태");
        throw Exception('Unexpected status code: ${response.statusCode}');
      }

    }catch(e){
      print('❌ [PAGE_NAVIGATION] checkSms() 에러 발생: $e');
      _errorMessage = '인증에 실패했습니다';
    }finally{
      _isLoading = false;
      print('🔍 [PAGE_NAVIGATION] checkSms() 완료 - 현재 페이지: $_currentPageIndex');
      _restorePageIndex(tempPageIndex);
      notifyListeners();
    }
  }

  // 또는 더 안전한 방법 - animateToPage 사용
  void _restorePageIndex(int targetPageIndex){
    _isRestoring = true;
    print('[PAGE_NAVIGATION_LOG] 페이지 복원 시도: $targetPageIndex');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        print('[PAGE_NAVIGATION_LOG] 페이지 복원 실행: $targetPageIndex');


        // animateToPage를 사용하면 onPageChanged가 자동으로 호출됨
        pageController.animateToPage(
          targetPageIndex,
          duration: const Duration(milliseconds: 1), // 매우 짧은 애니메이션
          curve: Curves.linear,
        );
        _forcePageControllerSync(targetPageIndex-1);



      } else {
        print('[PAGE_NAVIGATION_LOG] PageController 연결되지 않음, 인덱스만 설정: $targetPageIndex');
        _currentPageIndex = targetPageIndex;
        notifyListeners();
      }

      _isRestoring = false;
    });
  }

  void _forcePageControllerSync(int targetPageIndex) {
    print('[PAGE_NAVIGATION_LOG] PageController 강제 재동기화: $targetPageIndex');

    // 기존 PageController 해제
    pageController.dispose();

    // 새로운 PageController 생성 (원하는 페이지로 초기화)
    pageController = PageController(initialPage: targetPageIndex);
    _currentPageIndex = targetPageIndex;

    notifyListeners();
  }



  // 페이지 이동 시 _isSendClicked 관리 메서드 수정
  void resetPageState() {
    print('🔄 [PAGE_NAVIGATION] resetPageState() 호출됨 - 현재 페이지: $_currentPageIndex');

    if (_currentPageIndex != IdentityVerificationStep.smsVerification.index) {
      print('🔄 [PAGE_NAVIGATION] SMS 인증 페이지가 아니므로 _isSendClicked 초기화');
      _isSendClicked = false;
    }
  }

  // 리소스 정리
  @override
  void dispose() {
    print('🗑️ [PAGE_NAVIGATION] ViewModel dispose() 호출됨');
    pageController.dispose();
    telController.dispose();
    super.dispose();
  }
}