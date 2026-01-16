import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

/// Widget untuk menampilkan empty state "Tidak ada data untuk ditampilkan"
class ProfileEmptyState extends StatelessWidget {
  final String? message;

  const ProfileEmptyState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Document icon illustration
          _buildDocumentIcon(colors),
          SizedBox(height: 16.h),

          // Text
          Text(
            message ?? 'Tidak ada data untuk\nditampilkan',
            textAlign: TextAlign.center,
            style: AppTextStyles.h4(colors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentIcon(ThemeColors colors) {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.divider, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Document lines illustration
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLine(colors, width: 40.w),
              SizedBox(height: 6.h),
              _buildLine(colors, width: 32.w),
              SizedBox(height: 6.h),
              _buildLine(colors, width: 36.w),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLine(ThemeColors colors, {required double width}) {
    return Container(
      width: width,
      height: 4.h,
      decoration: BoxDecoration(
        color: colors.divider,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}
