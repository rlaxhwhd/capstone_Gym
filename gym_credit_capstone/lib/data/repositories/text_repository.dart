import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class TextRepository {
  Future<List<Map<String, dynamic>>> loadJsonListFromLocal(String path) async {
    final String jsonString = await rootBundle.loadString(path);
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.cast<Map<String, dynamic>>();
  }
}
