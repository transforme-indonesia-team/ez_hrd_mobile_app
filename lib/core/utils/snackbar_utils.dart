import 'package:flutter/material.dart';

/// Extension untuk menampilkan SnackBar dengan mudah dari BuildContext
extension SnackBarExtension on BuildContext {
  /// Menampilkan snackbar bahwa menu belum tersedia
  void showMenuNotAvailable(String menuName) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text('Menu "$menuName" belum tersedia'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Menampilkan snackbar bahwa fitur belum tersedia
  void showFeatureNotAvailable(String featureName) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text('$featureName belum tersedia'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Menampilkan snackbar dengan pesan custom
  void showSnackBarMessage(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }
}
