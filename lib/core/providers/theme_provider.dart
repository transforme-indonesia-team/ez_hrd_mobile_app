import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider untuk mengelola state tema aplikasi.
/// Menyimpan preferensi tema ke SharedPreferences agar persisten.
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';

  bool _isDarkMode = false;
  bool _isInitialized = false;

  /// Apakah dark mode aktif
  bool get isDarkMode => _isDarkMode;

  /// Apakah sudah diinisialisasi
  bool get isInitialized => _isInitialized;

  /// Label untuk ditampilkan di UI
  String get modeLabel => _isDarkMode ? 'Mode Gelap' : 'Mode Terang';

  /// ThemeMode untuk MaterialApp
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Inisialisasi - load dari SharedPreferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  /// Toggle antara Light dan Dark mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    // Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }

  /// Set tema secara langsung
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    }
  }
}
