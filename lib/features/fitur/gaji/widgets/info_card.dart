import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

/// Info card biru untuk menampilkan informasi penting
class InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: colors.primaryBlue.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySemiBold(colors.primaryBlue),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    message,
                    style: AppTextStyles.caption(colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (icon != null) ...[
              SizedBox(width: 8.w),
              Icon(icon, color: colors.primaryBlue, size: 20.sp),
            ],
          ],
        ),
      ),
    );
  }
}
