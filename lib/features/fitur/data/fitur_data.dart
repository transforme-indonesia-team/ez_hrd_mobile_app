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
              id: 'profil_perusahaan',
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
              id: 'pengajuan_cuti',
              title: 'Pengajuan Cuti',
              icon: Icons.calendar_month_outlined,
            ),
            FiturItemModel(
              id: 'saldo_cuti',
              title: 'Saldo Cuti',
              icon: Icons.event_available_outlined,
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
      categories: [
        FiturCategoryModel(
          name: 'Tugas & Harian',
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
            FiturItemModel(
              id: 'manajemen_tugas',
              title: 'Manajemen Tugas',
              icon: Icons.task_alt_outlined,
            ),
            FiturItemModel(
              id: 'laporan_tugas',
              title: 'Laporan Tugas',
              icon: Icons.list,
            ),
          ],
        ),

        FiturCategoryModel(
          name: 'Cuti',
          backgroundColor: Colors.blue.withValues(alpha: 0.2),
          iconColor: const Color.fromARGB(255, 101, 191, 244),
          items: [
            FiturItemModel(
              id: 'pengajuan_cuti',
              title: 'Pengajuan Cuti',
              icon: Icons.calendar_month_outlined,
            ),
            FiturItemModel(
              id: 'saldo_cuti',
              title: 'Saldo Cuti',
              icon: Icons.event_available_outlined,
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
            FiturCategoryModel(name: category.name, items: filteredItems),
          );
        }
      }

      if (filteredCategories.isNotEmpty) {
        result.add(
          FiturSectionModel(name: section.name, categories: filteredCategories),
        );
      }
    }

    return result;
  }
}
