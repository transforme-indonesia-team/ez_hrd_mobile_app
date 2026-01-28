import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/models/overtime_employee_model.dart';

class OvertimeRequestCard extends StatelessWidget {
  final OvertimeEmployeeModel request;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const OvertimeRequestCard({
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
          spacing: 3.h,
          children: [
            // Header with title and edit button (if DRAFT)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Nomor Permintaan',
                    style: AppTextStyles.bodySemiBold(colors.textPrimary),
                  ),
                ),
                if (request.isDraft && onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit,
                      color: colors.primaryBlue,
                      size: 20.sp,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Edit',
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              request.displayOvertimeRequestNo,
              style: AppTextStyles.body(colors.textPrimary),
            ),
            SizedBox(height: 12.h),
            _buildInlineRow(colors, 'Karyawan', request.displayEmployeeName),
            SizedBox(height: 8.h),
            _buildInlineRow(colors, 'Tanggal', request.displayDateOvertime),
            SizedBox(height: 8.h),
            _buildInlineRow(colors, 'Waktu', request.displayTimeRange),
            SizedBox(height: 8.h),
            _buildStatusRow(colors),
            if (request.remarkOvertime != null &&
                request.remarkOvertime!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _buildInlineRow(
                colors,
                'Keterangan',
                request.remarkOvertime ?? '-',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInlineRow(ThemeColors colors, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label  ', style: AppTextStyles.bodySemiBold(colors.textPrimary)),
        Expanded(
          child: Text(value, style: AppTextStyles.body(colors.textPrimary)),
        ),
      ],
    );
  }

  Widget _buildStatusRow(ThemeColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Status  ', style: AppTextStyles.bodySemiBold(colors.textPrimary)),
        _StatusBadge(status: request.displayStatus),
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

    Color backgroundColor;
    Color textColor;

    if (statusUpper == 'DRAFT') {
      backgroundColor = const Color(0xFFE0E7FF);
      textColor = const Color(0xFF4338CA);
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
      backgroundColor = colors.divider;
      textColor = colors.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(status, style: AppTextStyles.caption(textColor)),
    );
  }
}
