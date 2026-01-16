import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';

class FiturItemGrid extends StatelessWidget {
  final FiturItemModel item;
  final Color? categoryBackgroundColor;
  final Color? categoryIconColor;
  final VoidCallback? onTap;

  const FiturItemGrid({
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 2.h),
          // Icon container - wrapped in Flexible with FittedBox
          Flexible(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: categoryBackgroundColor ?? colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.divider, width: 1),
                ),
                child: Icon(
                  item.icon,
                  size: 22.sp,
                  color: categoryIconColor ?? colors.primaryBlue,
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          // Title - wrapped in Flexible to prevent overflow
          Flexible(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.xxSmall(colors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
