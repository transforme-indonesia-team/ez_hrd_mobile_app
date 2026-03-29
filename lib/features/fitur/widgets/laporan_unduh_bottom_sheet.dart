import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

class LaporanActionHelper {
  static void showUnduhOptions(BuildContext context, ThemeColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.only(top: 12.h, bottom: MediaQuery.of(context).padding.bottom + 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              _buildOption(context, colors, Icons.picture_as_pdf_outlined, 'PDF'),
              _buildOption(context, colors, Icons.table_view_outlined, 'Excel'),
              _buildOption(context, colors, Icons.email_outlined, 'Kirim ke Email'),
              _buildOption(context, colors, Icons.visibility_outlined, 'Lihat Langsung'),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildOption(BuildContext context, ThemeColors colors, IconData icon, String title) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Action logic here
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
        child: Row(
          children: [
            Icon(icon, color: colors.textSecondary, size: 22.sp),
            SizedBox(width: 16.w),
            Text(
              title,
              style: AppTextStyles.body(colors.textPrimary).copyWith(fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}
