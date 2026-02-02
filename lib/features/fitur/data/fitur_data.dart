import 'package:flutter/material.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';

class FiturData {
  FiturData._();

  static final List<FiturSectionModel> sections = [
    FiturSectionModel(
      name: 'Inti',
      categories: [
        FiturCategoryModel(
          name: 'Perusahaan',
          backgroundColor: Colors.blue.withValues(alpha: 0.2),
          items: [
            FiturItemModel(
              id: 'profile_perusahaan',
              title: 'Profil Perusahaan',
              icon: Icons.business_outlined,
            ),
            FiturItemModel(
              id: 'kebijakan_perusahaan',
              title: 'Kebijakan Perusahaan',
              icon: Icons.policy_outlined,
            ),
            FiturItemModel(
              id: 'pengumuman',
              title: 'Pengumuman',
              icon: Icons.campaign_outlined,
            ),
            FiturItemModel(
              id: 'struktur_organisasi',
              title: 'Struktur Organisasi',
              icon: Icons.account_tree_outlined,
            ),
          ],
        ),

        FiturCategoryModel(
          name: 'Karyawan',
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          iconColor: Colors.green,
          items: [
            FiturItemModel(
              id: 'data_personal',
              title: 'Data Personal',
              icon: Icons.badge_outlined,
            ),
            FiturItemModel(
              id: 'permohonan_karyawan',
              title: 'Permohonan Karyawan',
              icon: Icons.person_add_outlined,
            ),
          ],
        ),
      ],
    ),

    FiturSectionModel(
      name: 'Waktu Kehadiran',
      categories: [
        FiturCategoryModel(
          name: 'Kehadiran',
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          iconColor: Colors.green,
          items: [
            FiturItemModel(
              id: 'daftar_kehadiran',
              title: 'Daftar Kehadiran',
              icon: Icons.checklist_outlined,
            ),
            FiturItemModel(
              id: 'permintaan_koreksi_kehadiran',
              title: 'Permintaan Koreksi Kehadiran',
              icon: Icons.edit_calendar_outlined,
            ),
          ],
        ),

        FiturCategoryModel(
          name: 'Cuti',
          backgroundColor: Colors.blue.withValues(alpha: 0.2),
          iconColor: const Color.fromARGB(255, 101, 191, 244),
          items: [
            FiturItemModel(
              id: 'permintaan_cuti',
              title: 'Permintaan Cuti',
              icon: Icons.calendar_month_outlined,
            ),
            FiturItemModel(
              id: 'jatah_cuti',
              title: 'Jatah Cuti',
              icon: Icons.event_available_outlined,
            ),
            FiturItemModel(
              id: 'kalender_cuti',
              title: 'Kalender Cuti',
              icon: Icons.event_note_outlined,
            ),
          ],
        ),
        FiturCategoryModel(
          name: "Lembur",
          backgroundColor: Colors.blue.withValues(alpha: 0.2),
          iconColor: const Color.fromARGB(255, 101, 191, 244),
          items: [
            FiturItemModel(
              id: 'permintaan_lembur',
              title: 'Permintaan Lembur',
              icon: Icons.work_history_outlined,
            ),
          ],
        ),
      ],
    ),

    FiturSectionModel(
      name: 'Aktivitas',
      hasLainnya: true,
      lainnyaTitle: 'Tugas & Saran',
      categories: [
        FiturCategoryModel(
          name: 'Aktivitas',
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          iconColor: Colors.green,
          items: [
            FiturItemModel(
              id: 'tugas',
              title: 'Tugas',
              icon: Icons.task_outlined,
            ),
            FiturItemModel(
              id: 'saran',
              title: 'Saran',
              icon: Icons.chat_bubble_outline,
            ),
          ],
        ),
        FiturCategoryModel(
          name: 'Manajemen',
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          iconColor: Colors.green,
          items: [
            FiturItemModel(
              id: 'manajemen_tugas',
              title: 'Manajemen Jenis Tugas',
              icon: Icons.task_alt_outlined,
            ),
          ],
        ),
        FiturCategoryModel(
          name: 'Laporan',
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          iconColor: Colors.green,
          items: [
            FiturItemModel(
              id: 'laporan_tugas',
              title: 'Laporan Tugas',
              icon: Icons.list_alt,
            ),
            FiturItemModel(
              id: 'laporan_saran',
              title: 'Laporan Saran',
              icon: Icons.list_alt,
            ),
          ],
        ),
      ],
      directCategories: [
        FiturCategoryModel(
          name: "Aktivitas Harian",
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          iconColor: Colors.green,
          items: [
            FiturItemModel(
              id: 'aktivitas_harian',
              title: 'Aktivitas Harian',
              icon: Icons.task_alt_rounded,
            ),
            FiturItemModel(
              id: 'manajemen_jenis_aktivitas',
              title: 'Manajemen Jenis Aktivitas',
              icon: Icons.list_alt_outlined,
            ),
            FiturItemModel(
              id: 'laporan_rekam_aktivitas',
              title: 'Laporan Rekam Aktivitas',
              icon: Icons.list_alt,
            ),
          ],
        ),
        FiturCategoryModel(
          name: "Pooling",
          backgroundColor: Colors.blue.withValues(alpha: 0.2),
          iconColor: const Color.fromARGB(255, 101, 191, 244),
          items: [
            FiturItemModel(
              id: 'polling',
              title: 'Polling',
              icon: Icons.poll_outlined,
            ),
          ],
        ),
      ],
    ),
    FiturSectionModel(
      name: 'Keuangan',
      categories: [
        FiturCategoryModel(
          name: 'Slip Gaji Saya',
          backgroundColor: Colors.orange.withValues(alpha: 0.2),
          iconColor: Colors.orange,
          items: [
            FiturItemModel(
              id: 'slip_gaji_saya',
              title: 'Slip Gaji Saya',
              icon: Icons.monetization_on_outlined,
            ),
            FiturItemModel(
              id: 'kata_sandi_slip_gaji',
              title: 'Kata Sandi Slip Gaji',
              icon: Icons.lock_outlined,
            ),
          ],
        ),
      ],
    ),
  ];

  static List<FiturSectionModel> search(String query) {
    if (query.isEmpty) return sections;

    final lowerQuery = query.toLowerCase();
    final result = <FiturSectionModel>[];

    for (final section in sections) {
      final filteredCategories = <FiturCategoryModel>[];

      for (final category in section.categories) {
        final filteredItems = category.items
            .where((item) => item.title.toLowerCase().contains(lowerQuery))
            .toList();

        if (filteredItems.isNotEmpty) {
          filteredCategories.add(
            FiturCategoryModel(
              name: category.name,
              items: filteredItems,
              backgroundColor: category.backgroundColor,
              iconColor: category.iconColor,
            ),
          );
        }
      }

      if (filteredCategories.isNotEmpty) {
        result.add(
          FiturSectionModel(
            name: section.name,
            categories: filteredCategories,
            hasLainnya: section.hasLainnya,
            lainnyaTitle: section.lainnyaTitle,
            directCategories: section.directCategories,
          ),
        );
      }
    }

    return result;
  }

  /// Mencari item berdasarkan ID dari semua sections dan categories
  /// Returns null jika tidak ditemukan
  static FiturItemModel? findItemById(String id) {
    for (final section in sections) {
      // Cari di categories
      for (final category in section.categories) {
        for (final item in category.items) {
          if (item.id == id) return item;
        }
      }
      // Cari di directCategories
      for (final category in section.directCategories) {
        for (final item in category.items) {
          if (item.id == id) return item;
        }
      }
    }
    return null;
  }

  /// Mencari category yang berisi item dengan ID tertentu
  /// Returns null jika tidak ditemukan
  static FiturCategoryModel? findCategoryByItemId(String id) {
    for (final section in sections) {
      // Cari di categories
      for (final category in section.categories) {
        for (final item in category.items) {
          if (item.id == id) return category;
        }
      }
      // Cari di directCategories
      for (final category in section.directCategories) {
        for (final item in category.items) {
          if (item.id == id) return category;
        }
      }
    }
    return null;
  }

  /// Mengambil list items berdasarkan list ID
  /// Item yang tidak ditemukan akan di-skip
  static List<FiturItemModel> getItemsByIds(List<String> ids) {
    final result = <FiturItemModel>[];
    for (final id in ids) {
      final item = findItemById(id);
      if (item != null) {
        result.add(item);
      }
    }
    return result;
  }
}
