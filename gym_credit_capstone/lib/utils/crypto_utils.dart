import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

const int _rsa2048MaxPlaintextLength = 254;

String encodeString(String input) {
  final bytes = utf8.encode(input);
  return base64Url.encode(bytes);
}

/// SSH 공개키에서 RSA 공개키 파라미터를 추출합니다.
RSAPublicKey parsePublicKeyFromSsh(String sshKey) {
  try {
    if (sshKey.trim().isEmpty) {
      throw ArgumentError('SSH key string cannot be empty');
    }

    // SSH 키 형식: "ssh-rsa <base64-encoded-key> <comment>"
    final parts = sshKey.trim().split(' ');
    if (parts.length < 2) {
      throw ArgumentError('Invalid SSH key format');
    }

    final keyType = parts[0];
    if (keyType != 'ssh-rsa') {
      throw ArgumentError('Only ssh-rsa keys are supported, got: $keyType');
    }

    final keyData = parts[1];

    // Base64 디코딩
    final keyBytes = base64.decode(keyData);

    // SSH 키 형식 파싱
    final reader = _SshKeyReader(keyBytes);

    // 키 타입 읽기 (ssh-rsa)
    final readKeyType = reader.readString();
    if (readKeyType != 'ssh-rsa') {
      throw ArgumentError('Key type mismatch: expected ssh-rsa, got $readKeyType');
    }

    // 공개 지수(exponent) 읽기
    final exponent = reader.readMpint();

    // 모듈러스(modulus) 읽기
    final modulus = reader.readMpint();

    return RSAPublicKey(modulus, exponent);
  } catch (e) {
    if (e is ArgumentError) rethrow;
    throw Exception('Failed to parse SSH public key: $e');
  }
}

/// SSH 키 데이터를 읽기 위한 헬퍼 클래스
class _SshKeyReader {
  final Uint8List _data;
  int _offset = 0;

  _SshKeyReader(this._data);

  /// 길이-값 형식의 문자열을 읽습니다.
  String readString() {
    final length = readUint32();
    if (_offset + length > _data.length) {
      throw Exception('Insufficient data for string');
    }

    final stringBytes = _data.sublist(_offset, _offset + length);
    _offset += length;

    return utf8.decode(stringBytes);
  }

  /// 32비트 부호 없는 정수를 읽습니다 (빅 엔디언).
  int readUint32() {
    if (_offset + 4 > _data.length) {
      throw Exception('Insufficient data for uint32');
    }

    final value = (_data[_offset] << 24) |
    (_data[_offset + 1] << 16) |
    (_data[_offset + 2] << 8) |
    _data[_offset + 3];
    _offset += 4;

    return value;
  }

  /// Multiple Precision Integer를 읽습니다.
  BigInt readMpint() {
    final length = readUint32();
    if (_offset + length > _data.length) {
      throw Exception('Insufficient data for mpint');
    }

    final mpintBytes = _data.sublist(_offset, _offset + length);
    _offset += length;

    // 빅 엔디언 바이트 배열을 BigInt로 변환
    if (mpintBytes.isEmpty) {
      return BigInt.zero;
    }

    // 음수 처리 (MSB가 1인 경우)
    bool isNegative = (mpintBytes[0] & 0x80) != 0;

    BigInt result = BigInt.zero;
    for (int i = 0; i < mpintBytes.length; i++) {
      result = (result << 8) + BigInt.from(mpintBytes[i]);
    }

    return isNegative ? result - (BigInt.one << (mpintBytes.length * 8)) : result;
  }
}

Future<String> _performEncryption(String plaintext, RSAPublicKey publicKey) async {
  final cipher = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

  final inputBytes = Uint8List.fromList(utf8.encode(plaintext));
  final cipherText = cipher.process(inputBytes);

  return base64Url.encode(cipherText);
}

/// SSH 공개키를 사용하여 RSA 암호화를 수행합니다.
Future<String> encryptWithRsa(String plaintext, String sshKey) async {
  try {
    if (plaintext.isEmpty) {
      throw ArgumentError('Plaintext cannot be empty');
    }

    print("utf8.encode(plaintext).length: ${utf8.encode(plaintext).length}");
    final plaintextBytes = utf8.encode(plaintext);
    if (plaintextBytes.length > _rsa2048MaxPlaintextLength) {
      throw ArgumentError(
          'Plaintext too long for RSA encryption. '
              'Maximum $_rsa2048MaxPlaintextLength bytes, '
              'got ${plaintextBytes.length} bytes'
      );
    }

    final publicKey = parsePublicKeyFromSsh(sshKey);
    return await _performEncryption(plaintext, publicKey);
  } catch (e) {
    if (e is ArgumentError) rethrow;
    throw Exception('RSA encryption failed: $e');
  }
}