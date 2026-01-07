import 'package:flutter/material.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';

/// Data menu favorit untuk beranda
/// Menggunakan warna yang sama dengan fitur section
class FavoriteMenuData {
  FavoriteMenuData._();

  static final List<FiturItemModel> items = [
    const FiturItemModel(
      id: 'permintaan_lembur',
      title: 'Permintaan Lembur',
      icon: Icons.work_history_outlined,
    ),
    const FiturItemModel(
      id: 'permintaan_cuti',
      title: 'Permintaan Cuti',
      icon: Icons.calendar_month_outlined,
    ),
    const FiturItemModel(
      id: 'slip_gaji_saya',
      title: 'Slip Gaji Saya',
      icon: Icons.monetization_on_outlined,
    ),
    const FiturItemModel(
      id: 'aktivitas_harian',
      title: 'Aktivitas Harian',
      icon: Icons.task_alt_rounded,
    ),
  ];

  /// Warna background dan icon untuk setiap menu item
  /// Disesuaikan dengan warna di fitur_data.dart
  static Color getBackgroundColor(String id) {
    switch (id) {
      case 'permintaan_lembur':
        return Colors.blue.withValues(alpha: 0.2);
      case 'permintaan_cuti':
        return Colors.blue.withValues(alpha: 0.2);
      case 'slip_gaji_saya':
        return Colors.orange.withValues(alpha: 0.2);
      case 'aktivitas_harian':
        return Colors.green.withValues(alpha: 0.2);
      default:
        return Colors.blue.withValues(alpha: 0.2);
    }
  }

  static Color getIconColor(String id) {
    switch (id) {
      case 'permintaan_lembur':
        return const Color.fromARGB(255, 101, 191, 244);
      case 'permintaan_cuti':
        return const Color.fromARGB(255, 101, 191, 244);
      case 'slip_gaji_saya':
        return Colors.orange;
      case 'aktivitas_harian':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
