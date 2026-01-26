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
  }) async {
    try {
      final encryptedPayload = _crypto.encryptPayload(payload);

      final response = await _dio.post(
        endpoint,
        data: {'payload': encryptedPayload},
      );

      return _decryptResponse(response, errorMessage: errorMessage);
    } on DioException catch (e) {
      throw _handleDioError(e, errorMessage);
    } catch (e) {
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

      return _decryptResponse(response, errorMessage: errorMessage);
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
      return _decryptResponse(response, errorMessage: errorMessage);
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
  }) {
    if (response.statusCode != 200) {
      throw Exception(
        errorMessage ?? 'Request gagal: ${response.statusMessage}',
      );
    }

    final encryptedResponse = response.data['response'] as String?;

    if (encryptedResponse == null) {
      throw Exception('Response tidak memiliki data terenkripsi');
    }

    final decryptedData = _crypto.decryptPayload(encryptedResponse);

    final original = decryptedData['original'] as Map<String, dynamic>?;

    debugPrint('DEBUG-API: Response: ${original.toString()}');

    if (original == null) {
      throw Exception('Response tidak valid');
    }

    if (original['code'] == 401 && _hasAuthToken()) {
      _onUnauthorized?.call();
      throw Exception(original['message'] ?? 'Sesi Anda telah berakhir');
    }

    if (original['status'] != true || original['code'] != 200) {
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
