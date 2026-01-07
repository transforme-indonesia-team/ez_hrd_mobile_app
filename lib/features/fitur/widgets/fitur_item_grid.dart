import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
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
        children: [
          SizedBox(height: 4.h),
          // Icon container
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: categoryBackgroundColor ?? colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.divider, width: 1),
            ),
            child: Icon(
              item.icon,
              size: 24.sp,
              color: categoryIconColor ?? colors.primaryBlue,
            ),
          ),
          SizedBox(height: 6.h),
          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
