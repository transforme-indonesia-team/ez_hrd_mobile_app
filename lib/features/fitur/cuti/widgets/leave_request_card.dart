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
            // Header: Nama Karyawan
            Text(
              request.displayEmployeeName,
              style: AppTextStyles.h4(colors.textPrimary, fontSize: 15.sp),
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
    final statusUpper = status.toUpperCase();

    Color backgroundColor;
    Color textColor;
    String displayText = status;

    if (statusUpper == 'DRAFT' || statusUpper == 'BELUM DIVERIFIKASI') {
      backgroundColor = const Color(0xFFFFF3CD);
      textColor = const Color(0xFFD68910);
      displayText = 'Belum diverifikasi';
    } else if (statusUpper == 'PENDING' || statusUpper.contains('WAITING')) {
      backgroundColor = const Color(0xFFFFF3CD);
      textColor = const Color(0xFFD68910);
    } else if (statusUpper == 'APPROVED' || statusUpper.contains('APPROVE')) {
      backgroundColor = const Color(0xFFD4EDDA);
      textColor = const Color(0xFF28A745);
    } else if (statusUpper == 'REJECTED' || statusUpper.contains('REJECT')) {
      backgroundColor = const Color(0xFFF8D7DA);
      textColor = const Color(0xFFDC3545);
    } else {
      backgroundColor = const Color(0xFFE5E7EB);
      textColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(displayText, style: AppTextStyles.caption(textColor)),
    );
  }
}
