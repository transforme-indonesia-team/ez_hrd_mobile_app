import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/features/profile/models/profile_detail_model.dart';

/// Widget untuk menu item di halaman profil detail
/// Menampilkan icon, title, subtitle (sub-items), dan chevron arrow
class ProfileMenuItem extends StatelessWidget {
  final ProfileMenuItemModel item;
  final Color? iconBackgroundColor;

  const ProfileMenuItem({
    super.key,
    required this.item,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          // color: colors.background,
          border: Border(
            bottom: BorderSide(color: colors.surface, width: 8.h),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with background
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                // color: iconBackgroundColor ?? colors.surface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(item.icon, size: 20.sp, color: colors.textSecondary),
            ),
            SizedBox(width: 12.w),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyMedium(colors.textPrimary),
                  ),
                  if (item.subItems.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      item.subtitle,
                      style: AppTextStyles.caption(colors.textSecondary),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),

            // Chevron arrow
            Icon(Icons.chevron_right, size: 24.sp, color: colors.inactiveGray),
          ],
        ),
      ),
    );
  }
}
