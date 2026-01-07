import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/color_palette.dart';

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
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
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
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: ColorPalette.orange500,
                  ),
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
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          children: [
            // Illustration - using a simple icon representation
            Container(
              width: 150.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: ColorPalette.orange50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 60.sp,
                    color: ColorPalette.orange300,
                  ),
                  Positioned(
                    left: 20.w,
                    top: 20.h,
                    child: Icon(
                      Icons.check_circle,
                      size: 20.sp,
                      color: ColorPalette.green500,
                    ),
                  ),
                  Positioned(
                    left: 25.w,
                    top: 45.h,
                    child: Icon(
                      Icons.check_circle,
                      size: 16.sp,
                      color: ColorPalette.green500,
                    ),
                  ),
                  Positioned(
                    left: 20.w,
                    top: 70.h,
                    child: Icon(
                      Icons.check_circle,
                      size: 18.sp,
                      color: ColorPalette.green500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Success text
            Text(
              'Horeee! Semua tugas sudah beres',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Semangat, terus produktif yaa!',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
