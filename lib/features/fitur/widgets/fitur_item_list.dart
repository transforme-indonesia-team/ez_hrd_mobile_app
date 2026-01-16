import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';

/// Item fitur dalam tampilan list
/// Icon di kiri dengan text di kanan
class FiturItemList extends StatelessWidget {
  final FiturItemModel item;
  final Color? categoryBackgroundColor;
  final Color? categoryIconColor;
  final VoidCallback? onTap;

  const FiturItemList({
    super.key,
    required this.item,
    this.categoryBackgroundColor,
    this.categoryIconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: categoryBackgroundColor ?? colors.surface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: colors.divider, width: 1),
              ),
              child: Icon(
                item.icon,
                size: 22.sp,
                color: categoryIconColor ?? colors.primaryBlue,
              ),
            ),
            SizedBox(width: 16.w),
            // Title
            Expanded(
              child: Text(
                item.title,
                style: AppTextStyles.bodyMedium(colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
