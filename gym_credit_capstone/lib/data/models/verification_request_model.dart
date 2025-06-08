class VerificationRequestModel {
  final String phoneNumber;
  final String carrier;
  final String fcmToken;
  final String deviceFingerprint;
  final String challengeCode;

  VerificationRequestModel({
    required this.phoneNumber,
    required this.carrier,
    required this.fcmToken,
    required this.deviceFingerprint,
    required this.challengeCode,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'carrier': carrier,
    'fcmToken': fcmToken,
    'deviceFingerprint': deviceFingerprint,
    'challengeCode': challengeCode,
  };
}
