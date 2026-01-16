import 'package:flutter/material.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

/// Header untuk section (background abu-abu)
/// Contoh: "Inti", "Waktu Kehadiran"
class FiturSectionHeader extends StatelessWidget {
  final String title;

  const FiturSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: colors.surface,
      child: Text(title, style: AppTextStyles.h4(colors.textPrimary)),
    );
  }
}
