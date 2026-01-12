import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrd_app/data/models/user_model.dart';
import 'package:hrd_app/data/services/auth_service.dart';

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

  Future<void> login({
    required String username,
    required String password,
    bool rememberMe = false,
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
