import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

import 'package:gym_credit_capstone/utils/crypto_utils.dart';

class ApiRepository {
  final String baseUrl;

  ApiRepository() : baseUrl = dotenv.env['S_URL'] ?? '';

  Future<http.Response> sendVerificationRequest({
    required String phoneNumber,
    required String carrier,
    required String fingerprint,
    required String challengeCode,
    required String hmac,
    required String timeStamp,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/verify/request');
      final pem = await rootBundle.loadString('assets/keys/public.pub');
      final compactData = '$phoneNumber|$carrier|$fingerprint|$challengeCode|$hmac|$timeStamp';

      if (compactData.length > 200) {
        throw Exception('Data is too long');
      }

      final encryptedData = await encryptWithRsa(compactData, pem);

      return await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'d': encryptedData}),
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timed out'),
      );

    } catch (e) {
      print('Verification request failed: $e');
      rethrow;
    }
  }




  Future<String> zeroKnowledgeHmac(String challengeCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify/key'),
      body: {'d': challengeCode},
    );
    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['hmac'];
  }



}