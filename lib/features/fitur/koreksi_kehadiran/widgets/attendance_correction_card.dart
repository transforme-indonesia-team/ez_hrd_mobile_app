import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/models/attendance_correction_model.dart';

class AttendanceCorrectionCard extends StatelessWidget {
  final AttendanceCorrectionModel request;
  final VoidCallback? onTap;

  const AttendanceCorrectionCard({
    super.key,
    required this.request,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent border
              Container(
                width: 4.w,
                decoration: BoxDecoration(
                  color: _getAccentColor(),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    bottomLeft: Radius.circular(12.r),
                  ),
                ),
              ),
              // Card content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Request number
                      Text(
                        request.displayRequestNo,
                        style: AppTextStyles.bodySemiBold(colors.textPrimary),
                      ),
                      Divider(color: colors.divider, thickness: 1.h),
                      SizedBox(height: 12.h),

                      // Permintaan Untuk & Permintaan Oleh
                      Row(
                        children: [
                          Expanded(
                            child: _buildLabelValue(
                              colors,
                              'Permintaan Untuk',
                              request.displayEmployeeName,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildLabelValue(
                              colors,
                              'Permintaan Oleh',
                              request.displayCreatedBy,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Tanggal Mulai & Tanggal Berakhir
                      Row(
                        children: [
                          Expanded(
                            child: _buildLabelValue(
                              colors,
                              'Tanggal Mulai',
                              request.displayStartDate,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildLabelValue(
                              colors,
                              'Tanggal Berakhir',
                              request.displayEndDate,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Status
                      Column(
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
                    ],
                  ),
                ),
              ),
            ],
          ),
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
          style: AppTextStyles.bodyMedium(colors.textPrimary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getAccentColor() {
    final status = request.displayStatus.toUpperCase();
    if (status == 'APPROVED' || status.contains('APPROVE')) {
      return const Color(0xFF28A745);
    } else if (status == 'REJECTED' || status.contains('REJECT')) {
      return const Color(0xFFDC3545);
    } else if (status == 'UNVERIFIED') {
      return const Color(0xFF4338CA);
    } else if (status == 'PENDING' || status.contains('WAITING')) {
      return const Color(0xFFD68910);
    }
    return const Color(0xFF9CA3AF);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusUpper = status.toUpperCase();

    // Convert status to readable format
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
      'UNVERIFIED' => (const Color(0xFFE0E7FF), const Color(0xFF4338CA)),
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
