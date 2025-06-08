import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

/// 보안 강화된 Nonce 생성기
String _generateSecureNonce() {
  final rnd = Random.secure();
  return List<int>.generate(16, (_) => rnd.nextInt(256))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
}

String _generateTimestampString() {
  final now = DateTime.now().toUtc(); // UTC 기준
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  final h = now.hour.toString().padLeft(2, '0');
  final min = now.minute.toString().padLeft(2, '0');
  final s = now.second.toString().padLeft(2, '0');
  final micro = now.microsecond.toString().padLeft(6, '0');

  return '$y$m$d$h$min$s${micro}Z';
}

/// 챌린지 원문 생성 유틸
Future<(String challenge, String timeStamp)> generateChallengePlain(String text) async {
  final timeStamp = _generateTimestampString();
  final challengePlain = '$text|$timeStamp';

  final bytes = utf8.encode(challengePlain);
  final challengeHash = sha256.convert(bytes).toString();

  return (challengeHash.substring(20,28), timeStamp);
}