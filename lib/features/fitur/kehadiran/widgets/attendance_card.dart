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

                if (attendance.isAbsent) ...[
                  GestureDetector(
                    onTap: () => _showAbsentActionSheet(context),
                    child: Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ColorPalette.red500,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '!',
                          style: TextStyle(
                            color: ColorPalette.red500,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
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

            SizedBox(height: 12.h),
            Divider(height: 1, color: colors.divider),
            SizedBox(height: 12.h),

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
                color: colors.card,
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
                      color: ColorPalette.slate400,
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

            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: attendance.remarkSchedule == "ABS"
                    ? ColorPalette.red50
                    : ColorPalette.green50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                attendance.remarkSchedule ?? "-",
                style: AppTextStyles.small(
                  attendance.remarkSchedule == "ABS"
                      ? ColorPalette.red500
                      : ColorPalette.green500,
                ).copyWith(fontWeight: FontWeight.w600),
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

  void _showAbsentActionSheet(BuildContext context) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Message
            Text(
              'Tampaknya ada masalah dengan status kehadiran Kamu. Permintaan cuti atau koreksi kehadiran segera!',
              style: AppTextStyles.body(colors.textPrimary),
            ),
            SizedBox(height: 20.h),

            // Label
            Text(
              'Permintaan untuk',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
            SizedBox(height: 12.h),

            // Cuti button
            _buildActionButton(
              context,
              colors,
              label: 'Cuti',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to cuti screen
              },
            ),
            SizedBox(height: 12.h),

            // Koreksi Kehadiran button
            _buildActionButton(
              context,
              colors,
              label: 'Koreksi Kehadiran',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to koreksi kehadiran screen
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeColors colors, {
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: colors.divider),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium(colors.primaryBlue),
          ),
        ),
      ),
    );
  }
}
