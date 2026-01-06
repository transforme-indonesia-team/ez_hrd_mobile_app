import 'package:flutter/material.dart';

/// Kelas untuk menyimpan semua konstanta warna aplikasi.
/// Mendukung Light Mode dan Dark Mode.
class AppColors {
  // Private constructor - tidak bisa di-instantiate
  AppColors._();

  // ============================================
  // LIGHT MODE COLORS
  // ============================================
  static const Color primaryBlueLight = Color(0xFF2563EB);
  static const Color primaryBlueDarkVariant = Color(0xFF1D4ED8);
  static const Color primaryBlueLightVariant = Color(0xFF3B82F6);

  static const Color buttonBlueLight = Color(0xFF3B82F6);
  static const Color buttonBlueDarkVariant = Color(0xFF2563EB);

  static const Color inputFillLight = Color(0xFFF8FAFC);
  static const Color inputBorderLight = Color(0xFF93C5FD);

  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color dividerLight = Color(0xFFE5E7EB);

  static const Color inactiveGrayLight = Color(0xFF9CA3AF);

  // ============================================
  // DARK MODE COLORS (Polished & Premium)
  // ============================================

  // Primary blue - sedikit lebih cerah di dark mode
  static const Color primaryBlueDark = Color(0xFF60A5FA);
  static const Color primaryBlueDarkDark = Color(0xFF3B82F6);
  static const Color primaryBlueLightDark = Color(0xFF93C5FD);

  // Button - gradient TERANG untuk dark mode (lebih menonjol)
  static const Color buttonBlueDark = Color(0xFF60A5FA); // Biru terang
  static const Color buttonBlueDarkDark = Color(0xFF3B82F6); // Biru medium

  // Input - lebih terang untuk kontras yang lebih baik
  static const Color inputFillDark = Color(
    0xFF1F2937,
  ); // Lebih gelap tapi dengan hint biru
  static const Color inputBorderDark = Color(
    0xFF4B5563,
  ); // Border lebih visible

  // Text - kontras yang lebih baik
  static const Color textPrimaryDark = Color(0xFFE5E7EB); // Tetap soft
  static const Color textSecondaryDark = Color(
    0xFFD1D5DB,
  ); // Lebih terang (#CCCCCC-ish)

  // Background - sedikit lebih hangat
  static const Color backgroundDark = Color(
    0xFF0F172A,
  ); // Dark navy, lebih premium
  static const Color surfaceDark = Color(
    0xFF1E293B,
  ); // Surface dengan hint biru
  static const Color dividerDark = Color(0xFF334155); // Divider lebih visible

  static const Color inactiveGrayDark = Color(
    0xFF64748B,
  ); // Sedikit lebih terang

  // ============================================
  // STATUS COLORS (sama untuk light & dark)
  // ============================================
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ============================================
  // GRADIENT HELPERS
  // ============================================
  static List<Color> buttonGradient(bool isDark) => isDark
      ? [buttonBlueDark, buttonBlueDarkDark]
      : [buttonBlueLight, buttonBlueDarkVariant];

  static List<Color> buttonGradientDisabled(bool isDark) => isDark
      ? [buttonBlueDark.withOpacity(0.5), buttonBlueDarkDark.withOpacity(0.5)]
      : [
          buttonBlueLight.withOpacity(0.5),
          buttonBlueDarkVariant.withOpacity(0.5),
        ];
}

/// Extension untuk akses warna yang theme-aware melalui BuildContext.
/// Gunakan: context.colors.primaryBlue
extension AppColorsExtension on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  _ThemeColors get colors => _ThemeColors(_isDark);
}

/// Helper class untuk warna tema
class _ThemeColors {
  final bool isDark;

  _ThemeColors(this.isDark);

  // Primary Colors
  Color get primaryBlue =>
      isDark ? AppColors.primaryBlueDark : AppColors.primaryBlueLight;
  Color get primaryBlueDark =>
      isDark ? AppColors.primaryBlueDarkDark : AppColors.primaryBlueDarkVariant;
  Color get primaryBlueLight => isDark
      ? AppColors.primaryBlueLightDark
      : AppColors.primaryBlueLightVariant;

  // App Title - PUTIH di dark mode, biru tua di light mode
  Color get appTitle => isDark
      ? const Color(0xFFFFFFFF) // Putih
      : AppColors.primaryBlueDarkVariant; // Biru tua

  // Link Color - Cyan terang di dark mode, biru di light mode
  Color get linkColor => isDark
      ? const Color(0xFF67E8F9) // Cyan terang
      : AppColors.primaryBlueLight;

  // Button Colors
  Color get buttonBlue =>
      isDark ? AppColors.buttonBlueDark : AppColors.buttonBlueLight;
  Color get buttonBlueDark =>
      isDark ? AppColors.buttonBlueDarkDark : AppColors.buttonBlueDarkVariant;

  // Input Colors
  Color get inputFill =>
      isDark ? AppColors.inputFillDark : AppColors.inputFillLight;
  Color get inputBorder =>
      isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight;

  // Text Colors
  Color get textPrimary =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textSubtitle => textSecondary;

  // Background Colors
  Color get background =>
      isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get surface => isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get divider => isDark ? AppColors.dividerDark : AppColors.dividerLight;

  // Neutral Colors
  Color get inactiveGray =>
      isDark ? AppColors.inactiveGrayDark : AppColors.inactiveGrayLight;

  // Status Colors
  Color get success => AppColors.success;
  Color get error => AppColors.error;
  Color get warning => AppColors.warning;
  Color get info => AppColors.info;

  // Gradients
  List<Color> get buttonGradient => AppColors.buttonGradient(isDark);
  List<Color> get buttonGradientDisabled =>
      AppColors.buttonGradientDisabled(isDark);
}
