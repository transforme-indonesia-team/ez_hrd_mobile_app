import 'package:flutter/material.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

/// Header untuk category
/// Contoh: "Perusahaan", "Karyawan", "Kehadiran", "Cuti"
class FiturCategoryHeader extends StatelessWidget {
  final String title;

  const FiturCategoryHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: AppTextStyles.bodySemiBold(colors.textPrimary)),
    );
  }
}
