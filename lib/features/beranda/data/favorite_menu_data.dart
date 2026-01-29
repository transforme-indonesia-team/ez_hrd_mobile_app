import 'package:flutter/material.dart';
import 'package:hrd_app/features/fitur/data/fitur_data.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';

class FavoriteMenuData {
  FavoriteMenuData._();

  /// Daftar ID menu yang dijadikan favorit
  /// Ubah list ini untuk mengubah menu favorit yang tampil di beranda
  static const List<String> _favoriteIds = [
    'permintaan_lembur',
    'permintaan_cuti',
    'slip_gaji_saya',
    'aktivitas_harian',
  ];

  /// Mengambil list item favorit dari FiturData berdasarkan ID
  static List<FiturItemModel> get items {
    return FiturData.getItemsByIds(_favoriteIds);
  }

  /// Mengambil background color dari category item di FiturData
  static Color getBackgroundColor(String id) {
    final category = FiturData.findCategoryByItemId(id);
    return category?.backgroundColor ?? Colors.blue.withValues(alpha: 0.2);
  }

  /// Mengambil icon color dari category item di FiturData
  static Color getIconColor(String id) {
    final category = FiturData.findCategoryByItemId(id);
    return category?.iconColor ?? Colors.blue;
  }
}
