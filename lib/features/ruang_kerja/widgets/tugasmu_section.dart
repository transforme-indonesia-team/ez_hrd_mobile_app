import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';

/// Section Tugasmu hari ini
class TugasmuSection extends StatelessWidget {
  final List<dynamic>? tasks;
  final VoidCallback? onLainnyaTap;

  const TugasmuSection({super.key, this.tasks, this.onLainnyaTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasTasks = tasks != null && tasks!.isNotEmpty;

    return Container(
      color: colors.background,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tugasmu hari ini',
                style: AppTextStyles.bodySemiBold(colors.textPrimary),
              ),
              TextButton(
                onPressed: onLainnyaTap ?? () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lainnya',
                  style: AppTextStyles.bodyMedium(colors.primaryBlue),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Content or success state
          if (hasTasks) _buildTasksList(colors) else _buildSuccessState(colors),
        ],
      ),
    );
  }

  Widget _buildTasksList(dynamic colors) {
    // TODO: Implement actual tasks list when data is available
    return const SizedBox.shrink();
  }

  Widget _buildSuccessState(dynamic colors) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          children: [
            // Illustration - using todo.png asset
            Image.asset(
              'assets/images/todo.png',
              height: 220.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16.h),
            // Success text
            Text(
              'Horeee! Semua tugas sudah beres',
              style: AppTextStyles.bodySemiBold(colors.textPrimary),
            ),
            SizedBox(height: 4.h),
            Text(
              'Semangat, terus produktif yaa!',
              style: AppTextStyles.body(colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
