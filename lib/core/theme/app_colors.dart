import 'package:flutter/material.dart';

/// Kelas untuk menyimpan semua konstanta warna aplikasi.
/// Gunakan ini agar warna konsisten di seluruh aplikasi dan mudah diubah.
class AppColors {
  // Private constructor - tidak bisa di-instantiate
  AppColors._();

  // ============================================
  // PRIMARY COLORS (Warna Utama)
  // ============================================
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueDark = Color(0xFF1D4ED8);
  static const Color primaryBlueLight = Color(0xFF3B82F6);

  // ============================================
  // BUTTON COLORS (Warna Tombol)
  // ============================================
  static const Color buttonBlue = Color(0xFF3B82F6);
  static const Color buttonBlueDark = Color(0xFF2563EB);

  // ============================================
  // INPUT COLORS (Warna Input Field)
  // ============================================
  static const Color inputFillColor = Color(0xFFF8FAFC);
  static const Color inputBorderColor = Color(0xFF93C5FD);

  // ============================================
  // TEXT COLORS (Warna Teks)
  // ============================================
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textSubtitle = Color(0xFF6B7280);

  // ============================================
  // NEUTRAL COLORS (Warna Netral)
  // ============================================
  static const Color inactiveGray = Color(0xFF9CA3AF);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGray = Color(0xFFF3F4F6);

  // ============================================
  // STATUS COLORS (Warna Status)
  // ============================================
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ============================================
  // GRADIENT (Gradien untuk Tombol)
  // ============================================
  static const List<Color> buttonGradient = [buttonBlue, buttonBlueDark];
  static List<Color> buttonGradientDisabled = [
    buttonBlue.withOpacity(0.5),
    buttonBlueDark.withOpacity(0.5),
  ];
}
