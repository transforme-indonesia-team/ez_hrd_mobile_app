import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrd_app/data/models/user_model.dart';
import 'package:hrd_app/data/services/auth_service.dart';

/// Provider untuk mengelola state autentikasi user secara global.
/// 
/// Menyimpan data user yang login dan menyediakan method untuk:
/// - Login/Logout
/// - Cek status autentikasi
/// - Persist user data dengan SharedPreferences (remember me)
class AuthProvider extends ChangeNotifier {
  static const String _userKey = 'saved_user';
  static const String _rememberMeKey = 'remember_me';

  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  /// Initialize provider - load saved user if remember me was enabled
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

      if (rememberMe) {
        final userJson = prefs.getString(_userKey);
        if (userJson != null && userJson.isNotEmpty) {
          _user = UserModel.fromJsonString(userJson);
        }
      }
    } catch (e) {
      debugPrint('Error loading saved user: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Login dengan username dan password
  Future<void> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      final dummyResponse = {
        'id': 1,
        'name': 'SARUL WIDODO',
        'email': 'sarul@example.com',
        'token': 'dummy_token_dev_123',
        'role': 'CASHIER',
        'company': 'EZ Parking',
        'location': 'LOKASI BARU PARKIR',
        'employee_id': '90035857',
        'avatar_url': null,
      };

      _user = UserModel.fromJson(dummyResponse);

      if (rememberMe) {
        await _saveUser();
      }

      _isLoading = false;
      notifyListeners();

      return;

      final authService = AuthService();
      final response = await authService.login(
        username: username,
        password: password,
      );

      // Parse response ke UserModel
      _user = UserModel.fromJson(response);

      // Simpan user jika remember me aktif
      if (rememberMe) {
        await _saveUser();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Set user langsung (untuk OAuth atau token-based auth)
  void setUser(UserModel user, {bool rememberMe = false}) {
    _user = user;
    if (rememberMe) {
      _saveUser();
    }
    notifyListeners();
  }

  /// Logout - clear user data
  Future<void> logout() async {
    _user = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_rememberMeKey, false);
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
      await prefs.setBool(_rememberMeKey, true);
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
}
