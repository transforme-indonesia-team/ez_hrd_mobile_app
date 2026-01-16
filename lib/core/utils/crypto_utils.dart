import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../config/env_config.dart';

class CryptoUtils {
  static final CryptoUtils _instance = CryptoUtils._internal();
  factory CryptoUtils() => _instance;
  CryptoUtils._internal();

  late final encrypt.Key _key;
  late final encrypt.IV _iv;
  late final encrypt.Encrypter _encrypter;

  void initialize() {
    try {
      final keyBase64 = EnvConfig.encryptionKey;
      final ivBase64 = EnvConfig.encryptionIv;

      final keyBytes = base64.decode(keyBase64);
      final ivBytes = base64.decode(ivBase64);

      _key = encrypt.Key(keyBytes);
      _iv = encrypt.IV(ivBytes);

      _encrypter = encrypt.Encrypter(
        encrypt.AES(_key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
      );
    } catch (e) {
      throw Exception('Failed to initialize crypto: $e');
    }
  }

  String encryptPayload(Map<String, dynamic> data) {
    try {
      final plainText = jsonEncode(data);

      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      final encryptedBase64 = encrypted.base64;

      return encryptedBase64;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  Map<String, dynamic> decryptPayload(String encryptedBase64) {
    try {
      final decrypted = _encrypter.decrypt64(encryptedBase64, iv: _iv);

      final jsonData = jsonDecode(decrypted) as Map<String, dynamic>;

      return jsonData;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
}
