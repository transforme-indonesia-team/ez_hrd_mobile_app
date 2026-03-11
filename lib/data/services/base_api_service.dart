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

  // ======== DEBUG: Comment/uncomment baris ini untuk toggle env POSTMAN ========
  // Jika POSTMAN  → payload & response TIDAK di-encrypt/decrypt (plain JSON)
  // Jika null     → payload di-encrypt, response di-decrypt
  // ignore: prefer_typing_uninitialized_variables
  static const String _debugEnv = 'POSTMAN';
  // static const String? _debugEnv = null;
  // ============================================================================

  /// Apakah mode debug aktif (tanpa encrypt/decrypt)
  static bool get _isDebugMode => _debugEnv != null;

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

  // ===========================================================================
  // SETUP
  // ===========================================================================

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Pastikan semua header value string (bukan List)
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

  /// Buat Options dengan debug env header + extra headers
  Options _buildOptions({
    Map<String, String>? extraHeaders,
    String? contentType,
  }) {
    final Map<String, dynamic> headers = {};
    if (_debugEnv != null) headers['env'] = _debugEnv;
    if (extraHeaders != null) {
      extraHeaders.forEach((key, value) => headers[key] = value);
    }
    return Options(
      headers: headers,
      contentType: contentType,
      listFormat: ListFormat.csv,
    );
  }

  // ===========================================================================
  // GET
  // ===========================================================================

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? errorMessage,
  }) async {
    debugPrint('DEBUG-API: GET $endpoint (params: $queryParameters)');
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: _buildOptions(),
      );
      return _handleResponse(
        response,
        errorMessage: errorMessage,
        endpoint: endpoint,
      );
    } on DioException catch (e) {
      debugPrint('DEBUG-API: GET $endpoint - DioException: ${e.type}');
      throw _handleDioError(e, errorMessage);
    }
  }

  // ===========================================================================
  // POST (JSON)
  // ===========================================================================

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> payload, {
    String? errorMessage,
    Map<String, String>? extraHeaders,
  }) async {
    try {
      // Jika debug mode → kirim plain, kalau tidak → encrypt payload
      final dynamic data;
      if (_isDebugMode) {
        data = payload;
        debugPrint('DEBUG-API: POST $endpoint - Plain payload');
      } else {
        final encrypted = _crypto.encryptPayload(payload);
        data = {'payload': encrypted};
        debugPrint(
          'DEBUG-API: POST $endpoint - Encrypted (${encrypted.length} chars)',
        );
      }

      final response = await _dio.post(
        endpoint,
        data: data,
        options: _buildOptions(extraHeaders: extraHeaders),
      );
      debugPrint('DEBUG-API: POST $endpoint - Status: ${response.statusCode}');

      return _handleResponse(
        response,
        errorMessage: errorMessage,
        endpoint: endpoint,
      );
    } on DioException catch (e) {
      debugPrint(
        'DEBUG-API: POST $endpoint - DioException: ${e.type} - ${e.message}',
      );
      throw _handleDioError(e, errorMessage);
    }
  }

  // ===========================================================================
  // PUT — same pattern as POST
  // ===========================================================================

  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
    String? errorMessage,
    Map<String, String>? extraHeaders,
  }) async {
    try {
      final dynamic data;
      if (_isDebugMode) {
        data = body;
        debugPrint('DEBUG-API: PUT $endpoint - Plain payload');
      } else {
        final encrypted = _crypto.encryptPayload(body);
        data = {'payload': encrypted};
        debugPrint(
          'DEBUG-API: PUT $endpoint - Encrypted (${encrypted.length} chars)',
        );
      }

      final response = await _dio.put(
        endpoint,
        data: data,
        options: _buildOptions(extraHeaders: extraHeaders),
      );
      debugPrint('DEBUG-API: PUT $endpoint - Status: ${response.statusCode}');

      return _handleResponse(
        response,
        errorMessage: errorMessage,
        endpoint: endpoint,
      );
    } on DioException catch (e) {
      debugPrint(
        'DEBUG-API: PUT $endpoint - DioException: ${e.type} - ${e.message}',
      );
      throw _handleDioError(e, errorMessage);
    }
  }

  // ===========================================================================

  Future<Map<String, dynamic>> postFormData(
    String endpoint,
    FormData formData, {
    String? errorMessage,
  }) async {
    // Debug log form fields
    debugPrint('========== DEBUG FORM DATA ==========');
    debugPrint('Endpoint: $endpoint');
    for (var field in formData.fields) {
      debugPrint('Field: ${field.key} = ${field.value}');
    }
    for (var file in formData.files) {
      final f = file.value;
      debugPrint('File: ${file.key} (${f.filename}, ${f.length} bytes)');
    }
    debugPrint('======================================');

    try {
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: _buildOptions(contentType: 'multipart/form-data'),
      );

      return _handleResponse(
        response,
        errorMessage: errorMessage,
        endpoint: endpoint,
      );
    } on DioException catch (e) {
      debugPrint('DEBUG-API: FormData $endpoint - DioException: ${e.type}');
      throw _handleDioError(e, errorMessage);
    }
  }

  // ===========================================================================
  // DELETE
  // ===========================================================================

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    String? errorMessage,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: _buildOptions(),
      );
      return _handleResponse(
        response,
        errorMessage: errorMessage,
        endpoint: endpoint,
      );
    } on DioException catch (e) {
      debugPrint('DEBUG-API: DELETE $endpoint - DioException: ${e.type}');
      throw _handleDioError(e, errorMessage);
    }
  }

  // ===========================================================================
  // RESPONSE HANDLER — otomatis detect encrypted vs plain
  // ===========================================================================

  Map<String, dynamic> _handleResponse(
    Response response, {
    String? errorMessage,
    String? endpoint,
  }) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode < 200 || statusCode >= 300) {
      debugPrint('DEBUG-API-ERROR: Status $statusCode for $endpoint');
      throw Exception(
        errorMessage ?? 'Request gagal: ${response.statusMessage}',
      );
    }

    final responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      debugPrint(
        'DEBUG-API-ERROR: Unexpected format for $endpoint: ${responseData.runtimeType}',
      );
      throw Exception('Response format tidak valid');
    }

    // -----------------------------------------------------------------------
    // Cek apakah response encrypted (ada field 'response')
    // -----------------------------------------------------------------------
    final encryptedResponse = responseData['response'] as String?;

    if (encryptedResponse != null) {
      // Response encrypted → decrypt
      debugPrint('DEBUG-API: Decrypting response for $endpoint');
      return _decryptAndValidate(
        encryptedResponse,
        errorMessage: errorMessage,
        endpoint: endpoint,
      );
    }

    // -----------------------------------------------------------------------
    // Response TIDAK encrypted (plain JSON) — bisa karena:
    // 1. Mode debug (env POSTMAN)
    // 2. API tertentu memang tidak encrypt response
    // -----------------------------------------------------------------------
    debugPrint('DEBUG-API: Plain response for $endpoint');
    return _validatePlainResponse(
      responseData,
      errorMessage: errorMessage,
      endpoint: endpoint,
    );
  }

  /// Decrypt dan validasi response encrypted
  Map<String, dynamic> _decryptAndValidate(
    String encryptedResponse, {
    String? errorMessage,
    String? endpoint,
  }) {
    Map<String, dynamic> decryptedData;
    try {
      decryptedData = _crypto.decryptPayload(encryptedResponse);
    } catch (e) {
      debugPrint('DEBUG-API-ERROR: Decryption failed for $endpoint: $e');
      throw Exception('Gagal mendekripsi response: $e');
    }

    final original = decryptedData['original'] as Map<String, dynamic>?;

    if (original == null) {
      throw Exception('Response tidak valid');
    }

    // Cek 401 unauthorized
    if (original['code'] == 401 && _hasAuthToken()) {
      _onUnauthorized?.call();
      throw Exception(original['message'] ?? 'Sesi Anda telah berakhir');
    }

    // Validasi status
    final code = original['code'] as int?;
    if (original['status'] != true ||
        code == null ||
        code < 200 ||
        code >= 300) {
      throw Exception(original['message'] ?? errorMessage ?? 'Request gagal');
    }

    return decryptedData;
  }

  /// Validasi response plain (tanpa decrypt)
  Map<String, dynamic> _validatePlainResponse(
    Map<String, dynamic> responseData, {
    String? errorMessage,
    String? endpoint,
  }) {
    // Cek format standar API (punya 'code' dan 'status')
    if (responseData.containsKey('code') &&
        responseData.containsKey('status')) {
      // Cek 401
      if (responseData['code'] == 401 && _hasAuthToken()) {
        _onUnauthorized?.call();
        throw Exception(responseData['message'] ?? 'Sesi Anda telah berakhir');
      }

      final code = responseData['code'] as int?;
      if (responseData['status'] != true ||
          code == null ||
          code < 200 ||
          code >= 300) {
        throw Exception(
          responseData['message'] ?? errorMessage ?? 'Request gagal',
        );
      }
    }

    // Wrap dalam format {'original': ...} supaya konsisten
    return {'original': responseData};
  }

  // ===========================================================================
  // ERROR HANDLER
  // ===========================================================================

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

  // ===========================================================================
  // AUTH TOKEN
  // ===========================================================================

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // ===========================================================================
  // COMPANY ID
  // ===========================================================================

  void setCompanyId(String companyId) {
    _dio.options.headers['company-id'] = companyId;
  }

  void clearCompanyId() {
    _dio.options.headers.remove('company-id');
  }
}
