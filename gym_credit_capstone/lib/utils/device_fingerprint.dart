import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';

import 'package:gym_credit_capstone/data/repositories/auth_repository.dart';

/// 디바이스 지문 생성 유틸
Future<String> generateDeviceFingerprint(AuthRepository authRepo) async {
  final deviceInfo = DeviceInfoPlugin();
  final packageInfo = await PackageInfo.fromPlatform();
  final appVersion = packageInfo.version;

  final fcmToken = await authRepo.getFcmToken();

  if (fcmToken == null) {
    throw Exception('FCM 토큰이 없습니다.');
  }

  String deviceString;

  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;
    deviceString =
    '${android.brand}|${android.device}|${android.model}|'
        '${android.product}|${android.hardware}';
  } else if (Platform.isIOS) {
    final ios = await deviceInfo.iosInfo;
    deviceString =
    '${ios.name}|${ios.systemName}|${ios.systemVersion}|'
        '${ios.model}|${ios.localizedModel}';
  } else {
    throw UnsupportedError('지원하지 않는 플랫폼입니다.');
  }

  final rawInfo = '$fcmToken|$deviceString|$appVersion';
  final bytes = utf8.encode(rawInfo);
  final fingerprint = sha256.convert(bytes).toString();

  return fingerprint.substring(25,37);
}
