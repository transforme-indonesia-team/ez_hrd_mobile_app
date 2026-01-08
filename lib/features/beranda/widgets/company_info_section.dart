import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';

/// Section Informasi Perusahaan dengan empty state
class CompanyInfoSection extends StatelessWidget {
  final List<dynamic>? data;

  const CompanyInfoSection({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasData = data != null && data!.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      color: colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Informasi Perusahaan',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Content or empty state
          if (hasData) _buildContent(colors) else _buildEmptyState(colors),
        ],
      ),
    );
  }

  Widget _buildContent(dynamic colors) {
    // TODO: Implement actual content when data is available
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(dynamic colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 24.h),
          // Empty state illustration
          Icon(Icons.description_outlined, size: 80.sp, color: colors.divider),
          SizedBox(height: 16.h),
          Text(
            'Tidak ada data untuk\nditampilkan',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
