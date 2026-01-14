import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrd_app/data/models/user_model.dart';
import 'package:hrd_app/data/services/auth_service.dart';
import 'package:hrd_app/data/services/base_api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const String _userKey = 'saved_user';

  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  /// Initialize - Load saved user dan cek token expiry
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null && userJson.isNotEmpty) {
        final savedUser = UserModel.fromJsonString(userJson);

        // Cek apakah token masih valid
        if (_isTokenValid(savedUser.expiresAt)) {
          _user = savedUser;
          if (_user?.token != null) {
            BaseApiService().setAuthToken(_user!.token!);
          }
          debugPrint('Auto-login: Token masih valid');
        } else {
          // Token expired, hapus saved user
          await prefs.remove(_userKey);
          debugPrint('Auto-logout: Token sudah expired');
        }
      }
    } catch (e) {
      debugPrint('Error loading saved user: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Cek apakah token masih valid berdasarkan expires_at
  bool _isTokenValid(String? expiresAt) {
    if (expiresAt == null || expiresAt.isEmpty) {
      return false;
    }

    try {
      final expiryDate = DateTime.parse(expiresAt);
      final now = DateTime.now();

      // Token valid jika expiry date masih di masa depan
      return expiryDate.isAfter(now);
    } catch (e) {
      debugPrint('Error parsing expires_at: $e');
      return false;
    }
  }

  /// Login - Selalu simpan sesi setelah login sukses
  Future<void> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authService = AuthService();
      final response = await authService.login(
        username: username,
        password: password,
      );

      _user = UserModel.fromJson(response);

      if (_user?.token != null) {
        BaseApiService().setAuthToken(_user!.token!);
      }

      // Selalu simpan user setelah login sukses
      await _saveUser();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Set user (untuk penggunaan eksternal jika diperlukan)
  void setUser(UserModel user) {
    _user = user;
    _saveUser();
    notifyListeners();
  }

  /// Logout - clear user data
  Future<void> logout() async {
    _user = null;
    BaseApiService().clearAuthToken();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      debugPrint('Error clearing saved user: $e');
    }

    notifyListeners();
  }

  /// Simpan user ke SharedPreferences
  Future<void> _saveUser() async {
    if (_user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, _user!.toJsonString());
      debugPrint('User saved to SharedPreferences');
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  /// Update user data (misalnya setelah edit profile)
  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    _saveUser();
    notifyListeners();
  }

  /// Cek dan handle jika token expired saat runtime
  /// Panggil ini di tempat strategis (misalnya sebelum API call)
  bool checkAndHandleTokenExpiry() {
    if (_user == null) return false;

    if (!_isTokenValid(_user!.expiresAt)) {
      logout();
      return true; // Token expired, sudah logout
    }

    return false; // Token masih valid
  }

  // ============================================
  // AUTH FLOW METHODS (Forgot Password, OTP, etc)
  // ============================================

  final AuthService _authService = AuthService();

  /// Request forgot password - mengirim OTP ke email
  Future<Map<String, dynamic>> forgotPassword({
    required String usernameOrEmail,
  }) async {
    return _authService.forgotPassword(usernameOrEmail: usernameOrEmail);
  }

  /// Verify OTP - returns response with token_reset
  Future<Map<String, dynamic>> verifyOtp({
    required String usernameOrEmail,
    required String otp,
  }) async {
    return _authService.verifyOtp(usernameOrEmail: usernameOrEmail, otp: otp);
  }

  /// Reset password dengan token
  Future<Map<String, dynamic>> resetPassword({
    required String tokenReset,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return _authService.resetPassword(
      tokenReset: tokenReset,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }

  /// Change password (untuk user yang sudah login)
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }
}
