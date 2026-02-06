import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/config/env_config.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/data/models/attendance_employee_model.dart';

class AttendanceCard extends StatelessWidget {
  final AttendanceEmployeeModel attendance;
  final VoidCallback? onTap;
  final VoidCallback? onMorePressed;

  const AttendanceCard({
    super.key,
    required this.attendance,
    this.onTap,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Employee name + more button
            Row(
              children: [
                Expanded(
                  child: Text(
                    attendance.displayEmployeeName,
                    style: AppTextStyles.bodySemiBold(colors.textPrimary),
                  ),
                ),
                if (onMorePressed != null)
                  GestureDetector(
                    onTap: onMorePressed,
                    child: Icon(
                      Icons.more_vert,
                      color: colors.textSecondary,
                      size: 20.sp,
                    ),
                  ),
              ],
            ),
            Divider(height: 1, color: colors.divider),
            SizedBox(height: 16.h),

            // Tanggal
            Text('Tanggal', style: AppTextStyles.caption(colors.textSecondary)),
            SizedBox(height: 4.h),
            Text(
              attendance.displayDate,
              style: AppTextStyles.body(colors.textPrimary),
            ),
            SizedBox(height: 12.h),

            // Shift & Lembur row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shift',
                        style: AppTextStyles.caption(colors.textSecondary),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        attendance.displayShift,
                        style: AppTextStyles.body(colors.textPrimary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lembur',
                        style: AppTextStyles.caption(colors.textSecondary),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        attendance.displayOvertime,
                        style: AppTextStyles.body(colors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Time box
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Jam Masuk
                    Expanded(
                      child: _buildTimeSection(
                        colors,
                        label: 'Jam Masuk',
                        time: attendance.displayCheckIn,
                        hasTime: attendance.hasCheckIn,
                        photoUrl: attendance.attendancePhotoIn,
                      ),
                    ),
                    // Divider
                    Container(
                      width: 1,
                      color: colors.divider,
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    // Jam Keluar
                    Expanded(
                      child: _buildTimeSection(
                        colors,
                        label: 'Jam Keluar',
                        time: attendance.displayCheckOut,
                        hasTime: attendance.hasCheckOut,
                        photoUrl: attendance.attendancePhotoOut,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(
    ThemeColors colors, {
    required String label,
    required String time,
    required bool hasTime,
    String? photoUrl,
  }) {
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final fullPhotoUrl = hasPhoto ? '${EnvConfig.imageBaseUrl}$photoUrl' : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(label, style: AppTextStyles.small(colors.textPrimary)),
        SizedBox(height: 8.h),

        // Avatar
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: colors.divider,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: hasPhoto
              ? CachedNetworkImage(
                  imageUrl: fullPhotoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Icon(
                    Icons.person_outline,
                    color: colors.textSecondary,
                    size: 18.sp,
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person_outline,
                    color: colors.textSecondary,
                    size: 18.sp,
                  ),
                )
              : Icon(
                  Icons.person_outline,
                  color: colors.textSecondary,
                  size: 18.sp,
                ),
        ),

        // No Data text (if no time)
        if (!hasTime) ...[
          SizedBox(height: 4.h),
          Text('No Data', style: AppTextStyles.xSmall(ColorPalette.red400)),
        ],

        SizedBox(height: 4.h),

        // Time
        Text(
          time,
          style: AppTextStyles.bodySemiBold(
            hasTime ? ColorPalette.green600 : ColorPalette.red500,
          ),
        ),
      ],
    );
  }
}
