import 'package:hrd_app/data/services/base_api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _api = BaseApiService();

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    return _api.post('/user/login', {
      'username': username,
      'password': password,
    }, errorMessage: 'Login gagal');
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String usernameOrEmail,
  }) async {
    return _api.post('/user/forget-password', {
      'username_or_email': usernameOrEmail,
    }, errorMessage: 'Gagal mengirim permintaan');
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String usernameOrEmail,
    required String otp,
  }) async {
    return _api.post('/user/verify-otp', {
      'username_or_email': usernameOrEmail,
      'otp': otp,
    }, errorMessage: 'OTP tidak valid');
  }

  Future<Map<String, dynamic>> resetPassword({
    required String tokenReset,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return _api.post('/user/reset-password', {
      'token_reset': tokenReset,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    }, errorMessage: 'Gagal reset password');
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return _api.post('/user/change-password', {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    }, errorMessage: 'Gagal mengubah kata sandi');
  }
}
