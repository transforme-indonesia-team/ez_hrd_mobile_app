import 'dart:convert';
import 'package:flutter/foundation.dart';
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

      debugPrint('🔑 KEY dari env: $keyBase64');
      debugPrint('🔑 IV dari env: $ivBase64');

      // Decode dari Base64 ke bytes
      final keyBytes = base64.decode(keyBase64);
      final ivBytes = base64.decode(ivBase64);

      _key = encrypt.Key(keyBytes);
      _iv = encrypt.IV(ivBytes);

      _encrypter = encrypt.Encrypter(
        encrypt.AES(_key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
      );

      debugPrint('✅ Crypto initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize crypto: $e');
      throw Exception('Failed to initialize crypto: $e');
    }
  }

  /// Encrypt data JSON ke Base64 string
  String encryptPayload(Map<String, dynamic> data) {
    try {
      // 1. Convert JSON ke String
      final plainText = jsonEncode(data);
      print('📝 Plain text: $plainText');

      // 2. Encrypt
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);

      // 3. Convert ke Base64
      final encryptedBase64 = encrypted.base64;
      print('🔒 Encrypted: $encryptedBase64');

      return encryptedBase64;
    } catch (e) {
      print('❌ Encryption failed: $e');
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypt Base64 string ke JSON
  Map<String, dynamic>? decryptPayload(String encryptedBase64) {
    try {
      // 1. Decrypt dari Base64
      final decrypted = _encrypter.decrypt64(encryptedBase64, iv: _iv);
      print('🔓 Decrypted text: $decrypted');

      // 2. Parse JSON
      final jsonData = jsonDecode(decrypted) as Map<String, dynamic>;

      return jsonData;
    } catch (e) {
      print('❌ Decryption failed: $e');
      return null;
    }
  }
}
