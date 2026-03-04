import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

class NotificationCategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int itemCount;
  final VoidCallback? onTap;

  const NotificationCategoryTile({
    super.key,
    required this.icon,
    required this.label,
    required this.itemCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: colors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colors.primaryBlue, size: 18.sp),
            ),
            SizedBox(width: 12.w),

            // Label
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium(colors.textPrimary),
              ),
            ),

            // Item count badge
            if (itemCount > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8751A),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$itemCount',
                  style: AppTextStyles.caption(Colors.white),
                ),
              ),

            SizedBox(width: 6.w),
            Icon(Icons.chevron_right, color: colors.textSecondary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
