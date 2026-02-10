import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/models/attendance_employee_model.dart';

abstract class AttendanceActionBottomSheet {
  static void show(
    BuildContext context, {
    required AttendanceEmployeeModel attendance,
    VoidCallback? onDetailKehadiran,
    VoidCallback? onRiwayatKehadiran,
    VoidCallback? onTampilkan7Hari,
  }) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // Menu items
            _buildMenuItem(
              context,
              colors,
              icon: Icons.assignment_outlined,
              label: 'Detail Kehadiran',
              onTap: () {
                Navigator.pop(context);
                onDetailKehadiran?.call();
              },
            ),
            Divider(height: 1, color: colors.divider),

            _buildMenuItem(
              context,
              colors,
              icon: Icons.history,
              label: 'Riwayat Kehadiran',
              onTap: () {
                Navigator.pop(context);
                onRiwayatKehadiran?.call();
              },
            ),
            Divider(height: 1, color: colors.divider),

            _buildMenuItem(
              context,
              colors,
              icon: Icons.date_range_outlined,
              label: 'Tampilkan 7 Hari',
              onTap: () {
                Navigator.pop(context);
                onTampilkan7Hari?.call();
              },
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 12.h),
          ],
        ),
      ),
    );
  }

  static Widget _buildMenuItem(
    BuildContext context,
    ThemeColors colors, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(icon, color: colors.textSecondary, size: 22.sp),
            SizedBox(width: 16.w),
            Text(label, style: AppTextStyles.body(colors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
