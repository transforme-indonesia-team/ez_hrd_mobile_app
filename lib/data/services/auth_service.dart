import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
import 'package:hrd_app/core/config/env_config.dart';
import 'package:hrd_app/core/utils/crypto_utils.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final _crypto = CryptoUtils();

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final payload = {'username': username, 'password': password};

      final encryptedPayload = _crypto.encryptPayload(payload);

      final response = await _dio.post(
        '/apps/user/login',
        data: {'payload': encryptedPayload},
      );

      if (response.statusCode == 200) {
        final encryptedResponse = response.data['response'] as String?;

        if (encryptedResponse == null) {
          throw Exception('Response tidak memiliki data terenkripsi');
        }

        final decryptedData = _crypto.decryptPayload(encryptedResponse);

        if (decryptedData == null) {
          throw Exception('Gagal mendekripsi response');
        }

        final original = decryptedData['original'] as Map<String, dynamic>?;
        // debugPrint('DecryptedData: ${original.toString()}');

        if (original == null) {
          throw Exception('Response tidak valid');
        }

        if (original['status'] != true) {
          throw Exception(original['message'] ?? 'Login gagal');
        }

        return decryptedData;
      } else {
        throw Exception('Login gagal: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Login gagal');
      } else {
        throw Exception('Tidak dapat terhubung ke server');
      }
    } catch (e) {
      rethrow;
    }
  }
}
