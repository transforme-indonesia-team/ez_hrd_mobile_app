import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';

/// Screen Postingan dengan fitur empty state
class PostinganScreen extends StatelessWidget {
  const PostinganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors),
      body: _buildEmptyState(colors),
    );
  }

  PreferredSizeWidget _buildAppBar(dynamic colors) {
    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      titleSpacing: 16.w,
      title: Text(
        'Postingan',
        style: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Implement search
          },
          icon: Icon(Icons.search, color: colors.textSecondary, size: 24.sp),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildEmptyState(dynamic colors) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon illustration
            Icon(
              Icons.description_outlined,
              size: 100.sp,
              color: colors.divider,
            ),
            SizedBox(height: 24.h),
            // Title
            Text(
              'Fitur Tidak Diaktifkan',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            // Description
            Text(
              'Fitur ini tidak aktif untuk perusahaan Anda. Hubungi admin Anda untuk akses.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
