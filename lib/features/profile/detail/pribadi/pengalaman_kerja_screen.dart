import 'package:flutter/material.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';

class PengalamanKerjaScreen extends StatelessWidget {
  const PengalamanKerjaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pengalaman Kerja',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: const EmptyStateWidget(
        message: 'Belum ada data pengalaman kerja',
        icon: Icons.work_outline,
      ),
    );
  }
}
