import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/data/repositories/text_repository.dart';
import 'package:gym_credit_capstone/data/models/terms_text_model.dart';

class TermsDialogViewModel extends ChangeNotifier {
  final TextRepository _repository = TextRepository();

  bool _isLoading = false;
  String? _errorMessage;

  String? _termTitle;
  String? _effectiveDate;
  String? _company;
  String? _service;
  List<TermsSection>? _sections;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get termTitle => _termTitle;
  String? get effectiveDate => _effectiveDate;
  String? get company => _company;
  String? get service => _service;
  List<TermsSection>? get sections => _sections;

  final Map<String, String> _termsMap = {
    '서비스 이용 약관 동의': 'terms_and_conditions', // 파일명 맞춰주세요
    '개인정보 처리 약관 동의': 'privacy_policy', // 파일명 맞춰주세요
    '결제 이용 약관 동의': 'payment_terms' // 파일명 맞춰주세요
  };

  Future<void> loadTerms(String dialogTitle) async {
    _setLoading(true);

    final fileName = _termsMap[dialogTitle];
    if (fileName == null) {
      _setError('해당 약관을 찾을 수 없습니다.');
      return;
    }

    try {
      final doc = await _repository.loadJsonTermsFromAsset(fileName);

      _termTitle = doc.termTitle;
      _effectiveDate = doc.effectiveDate;
      _company = doc.company;
      _service = doc.service;
      _sections = doc.sections;

      _setLoading(false);
    } catch (e) {
      _setError('약관 불러오기 실패: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

}