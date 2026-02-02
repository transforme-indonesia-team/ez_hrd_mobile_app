import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/models/leave_employee_model.dart';

class LeaveRequestCard extends StatelessWidget {
  final LeaveEmployeeModel request;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const LeaveRequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nama Karyawan with edit button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.displayEmployeeName,
                        style: AppTextStyles.h4(
                          colors.textPrimary,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        request.displayRequestNo,
                        style: AppTextStyles.caption(colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (request.isDraft && onEdit != null)
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(
                      Icons.edit,
                      color: colors.primaryBlue,
                      size: 18.sp,
                    ),
                  ),
              ],
            ),
            Divider(height: 12.h, color: colors.divider),

            // Jenis Cuti
            _buildLabelValue(
              colors,
              'Jenis Cuti',
              request.displayLeaveTypeName,
            ),
            SizedBox(height: 12.h),

            // Date Range - 2 columns
            Text(
              'Date Range',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.formattedStartDate,
                    style: AppTextStyles.body(colors.textPrimary),
                  ),
                ),
                Expanded(
                  child: Text(
                    request.formattedEndDate,
                    style: AppTextStyles.body(colors.textPrimary),
                  ),
                ),
              ],
            ),
            Divider(height: 12.h, color: colors.divider),
            SizedBox(height: 5.h),

            // Status & Pembatalan - 2 columns
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: AppTextStyles.caption(colors.textSecondary),
                      ),
                      SizedBox(height: 4.h),
                      _StatusBadge(status: request.displayStatus),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pembatalan',
                        style: AppTextStyles.caption(colors.textSecondary),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        request.cancellationStatus,
                        style: AppTextStyles.body(colors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 12.h, color: colors.divider),
            SizedBox(height: 5.h),
            Text(
              'Keterangan',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
            SizedBox(height: 4.h),
            Text(
              request.displayRemark,
              style: AppTextStyles.body(colors.textPrimary, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelValue(ThemeColors colors, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(colors.textSecondary)),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTextStyles.body(colors.textPrimary, fontSize: 13.sp),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusUpper = status.toUpperCase();

    // Get display label and colors based on status
    // Convert status to readable format: PARTIALLY_APPROVED -> Partially Approved
    String label = status
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');

    final (Color backgroundColor, Color textColor) = switch (statusUpper) {
      'DRAFT' => (const Color(0xFFE0E7FF), const Color(0xFF4338CA)),
      'PENDING' => (const Color(0xFFFFF3CD), const Color(0xFFD68910)),
      _ when statusUpper.contains('WAITING') => (
        const Color(0xFFFFF3CD),
        const Color(0xFFD68910),
      ),
      _ when statusUpper.contains('APPROVE') => (
        const Color(0xFFD4EDDA),
        const Color(0xFF28A745),
      ),
      _ when statusUpper.contains('REJECT') => (
        const Color(0xFFF8D7DA),
        const Color(0xFFDC3545),
      ),
      _ when statusUpper.contains('CANCEL') => (
        const Color(0xFFF8D7DA),
        const Color(0xFFDC3545),
      ),
      _ => (colors.divider, colors.textSecondary),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(textColor),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
