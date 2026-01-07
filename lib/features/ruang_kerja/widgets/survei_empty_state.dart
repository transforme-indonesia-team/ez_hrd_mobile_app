import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';

/// Empty state widget untuk tab Polling/Survei
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
            // Icon illustration
            Icon(
              Icons.description_outlined,
              size: 80.sp,
              color: colors.divider,
            ),
            SizedBox(height: 16.h),
            // Text
            Text(
              'Tidak ada data untuk ditampilkan',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
