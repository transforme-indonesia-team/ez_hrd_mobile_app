import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/models/payslip_model.dart';

/// Card widget untuk menampilkan slip gaji
class PayslipCard extends StatelessWidget {
  final PayslipModel payslip;
  final VoidCallback? onTap;

  const PayslipCard({super.key, required this.payslip, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: colors.divider.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            // Icon/Avatar
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: colors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: colors.primaryBlue,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payslip.displayPeriod,
                    style: AppTextStyles.bodySemiBold(colors.textPrimary),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    payslip.displayEmployeeName,
                    style: AppTextStyles.caption(colors.textSecondary),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(Icons.chevron_right, color: colors.textSecondary, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
