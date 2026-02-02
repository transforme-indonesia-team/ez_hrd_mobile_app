import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:hrd_app/core/config/env_config.dart';
import 'package:hrd_app/core/constants/app_constants.dart';
import 'package:hrd_app/core/utils/crypto_utils.dart';

typedef UnauthorizedCallback = void Function();

class BaseApiService {
  static final BaseApiService _instance = BaseApiService._internal();
  factory BaseApiService() => _instance;
  BaseApiService._internal() {
    _setupInterceptors();
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: const Duration(
        seconds: AppConstants.apiConnectTimeoutSeconds,
      ),
      receiveTimeout: const Duration(
        seconds: AppConstants.apiReceiveTimeoutSeconds,
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final CryptoUtils _crypto = CryptoUtils();

  UnauthorizedCallback? _onUnauthorized;

  Dio get dio => _dio;
  CryptoUtils get crypto => _crypto;

  void setUnauthorizedCallback(UnauthorizedCallback callback) {
    _onUnauthorized = callback;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Ensure all header values are plain strings, not Lists
          options.headers.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              options.headers[key] = value.first.toString();
            }
          });
          handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          if (error.response?.statusCode == 401 && _hasAuthToken()) {
            _onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  bool _hasAuthToken() {
    return _dio.options.headers['Authorization'] != null;
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> payload, {
    String? errorMessage,
    Map<String, String>? extraHeaders,
  }) async {
    debugPrint('DEBUG-API: POST $endpoint - Starting request');
    try {
      debugPrint('DEBUG-API: POST $endpoint - Encrypting payload...');
      final encryptedPayload = _crypto.encryptPayload(payload);
      debugPrint(
        'DEBUG-API: POST $endpoint - Payload encrypted (${encryptedPayload.length} chars)',
      );

      Options? options;
      if (extraHeaders != null && extraHeaders.isNotEmpty) {
        // Ensure header values are plain strings, not arrays
        final Map<String, dynamic> cleanHeaders = {};
        extraHeaders.forEach((key, value) {
          cleanHeaders[key] = value;
        });
        options = Options(
          headers: cleanHeaders,
          // Prevent Dio from wrapping header values in lists
          listFormat: ListFormat.csv,
        );
      }

      debugPrint('DEBUG-API: POST $endpoint - Sending request to server...');
      final response = await _dio.post(
        endpoint,
        data: {'payload': encryptedPayload},
        options: options,
      );
      debugPrint(
        'DEBUG-API: POST $endpoint - Response received (status: ${response.statusCode})',
      );

      return _decryptResponse(
        response,
        errorMessage: errorMessage,
        endpoint: endpoint,
      );
    } on DioException catch (e) {
      debugPrint(
        'DEBUG-API: POST $endpoint - DioException: ${e.type} - ${e.message}',
      );
      throw _handleDioError(e, errorMessage);
    } catch (e) {
      debugPrint('DEBUG-API: POST $endpoint - Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postFormData(
    String endpoint,
    FormData formData, {
    String? errorMessage,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      // Check if response has encrypted format
      if (response.data is Map<String, dynamic> &&
          response.data['response'] != null) {
        return _decryptResponse(
          response,
          errorMessage: errorMessage,
          endpoint: endpoint,
        );
      }

      // Handle non-encrypted response (raw JSON from server)
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        // Wrap raw response in the expected format
        final rawData = response.data as Map<String, dynamic>;
        debugPrint('DEBUG-API: FormData raw response for $endpoint: $rawData');
        return {'original': rawData};
      } else {
        throw Exception(
          errorMessage ?? 'Request gagal: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e, errorMessage);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postRaw(
    String endpoint,
    Map<String, dynamic> data, {
    String? errorMessage,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          errorMessage ?? 'Request gagal: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e, errorMessage);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? errorMessage,
  }) async {
    debugPrint('DEBUG-API: Query Parameters: ${queryParameters.toString()}');
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return _decryptResponse(
        response,
        errorMessage: errorMessage,
        endpoint: endpoint,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, errorMessage);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRaw(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? errorMessage,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          errorMessage ?? 'Request gagal: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e, errorMessage);
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _decryptResponse(
    Response response, {
    String? errorMessage,
    String? endpoint,
  }) {
    final statusCode = response.statusCode ?? 0;

    // Accept 2xx status codes as success
    if (statusCode < 200 || statusCode >= 300) {
      debugPrint('DEBUG-API-ERROR: Status $statusCode for $endpoint');
      throw Exception(
        errorMessage ?? 'Request gagal: ${response.statusMessage}',
      );
    }

    final responseData = response.data;

    // Log raw response type for debugging intermittent issues
    debugPrint(
      'DEBUG-API: Response type for $endpoint: ${responseData.runtimeType}',
    );

    // Handle case where response is not a Map (e.g., String or null)
    if (responseData is! Map<String, dynamic>) {
      debugPrint('DEBUG-API-ERROR: Unexpected response format for $endpoint');
      debugPrint('DEBUG-API-ERROR: Raw data: $responseData');
      throw Exception('Response format tidak valid');
    }

    final encryptedResponse = responseData['response'] as String?;

    if (encryptedResponse == null) {
      // Maybe server returned raw JSON (not encrypted) - check if it has 'code' and 'status'
      if (responseData.containsKey('code') &&
          responseData.containsKey('status')) {
        debugPrint(
          'DEBUG-API: Raw (unencrypted) response detected for $endpoint',
        );
        return {'original': responseData};
      }

      // Log more details for debugging
      debugPrint('DEBUG-API-ERROR: No encrypted response for $endpoint');
      debugPrint('DEBUG-API-ERROR: Raw data: $responseData');
      throw Exception('Response tidak memiliki data terenkripsi');
    }

    // Try to decrypt, with error handling
    Map<String, dynamic> decryptedData;
    try {
      decryptedData = _crypto.decryptPayload(encryptedResponse);
    } catch (e) {
      debugPrint('DEBUG-API-ERROR: Decryption failed for $endpoint: $e');
      debugPrint(
        'DEBUG-API-ERROR: Encrypted length: ${encryptedResponse.length}',
      );
      throw Exception('Gagal mendekripsi response: $e');
    }

    final original = decryptedData['original'] as Map<String, dynamic>?;

    debugPrint('DEBUG-API: Response: ${original.toString()}');

    if (original == null) {
      throw Exception('Response tidak valid');
    }

    if (original['code'] == 401 && _hasAuthToken()) {
      _onUnauthorized?.call();
      throw Exception(original['message'] ?? 'Sesi Anda telah berakhir');
    }

    final code = original['code'] as int?;
    if (original['status'] != true ||
        code == null ||
        code < 200 ||
        code >= 300) {
      throw Exception(original['message'] ?? errorMessage ?? 'Request gagal');
    }

    return decryptedData;
  }

  Exception _handleDioError(DioException e, String? errorMessage) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Koneksi timeout. Silakan coba lagi.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return Exception('Tidak dapat terhubung ke server');
    }

    if (e.response != null) {
      if (e.response?.statusCode == 401 && _hasAuthToken()) {
        return Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      }
      final message = e.response?.data['message'];
      return Exception(message ?? errorMessage ?? 'Request gagal');
    }

    return Exception('Tidak dapat terhubung ke server');
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
