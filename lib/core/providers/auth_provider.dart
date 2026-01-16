import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrd_app/data/models/user_model.dart';
import 'package:hrd_app/data/services/auth_service.dart';
import 'package:hrd_app/data/services/base_api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const String _userKey = 'saved_user';

  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null && userJson.isNotEmpty) {
        final savedUser = UserModel.fromJsonString(userJson);

        if (_isTokenValid(savedUser.expiresAt)) {
          _user = savedUser;
          if (_user?.token != null) {
            BaseApiService().setAuthToken(_user!.token!);
          }
        } else {
          await prefs.remove(_userKey);
        }
      }
    } catch (_) {}

    _isInitialized = true;
    notifyListeners();
  }

  bool _isTokenValid(String? expiresAt) {
    if (expiresAt == null || expiresAt.isEmpty) {
      return false;
    }

    try {
      final expiryDate = DateTime.parse(expiresAt);
      final now = DateTime.now();

      return expiryDate.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(
        username: username,
        password: password,
      );

      _user = UserModel.fromJson(response);

      if (_user?.token != null) {
        BaseApiService().setAuthToken(_user!.token!);
      }

      await _saveUser();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void setUser(UserModel user) {
    _user = user;
    _saveUser();
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    BaseApiService().clearAuthToken();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (_) {}

    notifyListeners();
  }

  Future<void> _saveUser() async {
    if (_user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, _user!.toJsonString());
    } catch (_) {}
  }

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    _saveUser();
    notifyListeners();
  }

  bool checkAndHandleTokenExpiry() {
    if (_user == null) return false;

    if (!_isTokenValid(_user!.expiresAt)) {
      logout();
      return true;
    }

    return false;
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String usernameOrEmail,
  }) async {
    return _authService.forgotPassword(usernameOrEmail: usernameOrEmail);
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String usernameOrEmail,
    required String otp,
  }) async {
    return _authService.verifyOtp(usernameOrEmail: usernameOrEmail, otp: otp);
  }

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
