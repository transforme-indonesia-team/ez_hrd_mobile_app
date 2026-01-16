import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';

class SurveiEmptyState extends StatelessWidget {
  const SurveiEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.background,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80.sp,
              color: colors.divider,
            ),
            SizedBox(height: 16.h),
            Text(
              'Tidak ada data untuk ditampilkan',
              style: AppTextStyles.bodyMedium(colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
