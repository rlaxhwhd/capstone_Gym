import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gym_credit_capstone/data/models/terms_text_model.dart';

class TextRepository {
  static const String _termsAssetPath = 'assets/text/';

  Future<List<Map<String, dynamic>>> loadJsonListFromLocal(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('JSON List 로드 실패: \$e');
    }
  }

  Future<TermsDocument> loadJsonTermsFromAsset(String fileName) async {
    try {
      final jsonString = await rootBundle.loadString('$_termsAssetPath$fileName.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return TermsDocument.fromJson(jsonMap);
    } catch (e) {
      throw Exception('약관 JSON 로드 실패: \$e');
    }
  }
}
