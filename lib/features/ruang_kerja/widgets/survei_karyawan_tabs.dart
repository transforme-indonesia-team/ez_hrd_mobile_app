import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/color_palette.dart';

/// Widget untuk menampilkan tabs Polling dan Survei
class SurveiKaryawanTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const SurveiKaryawanTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.background,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Survei Karyawan',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          // Tabs - menggunakan Row dengan Expanded untuk menyebar rata
          Row(
            children: [
              Expanded(
                child: _buildTab(
                  context: context,
                  label: 'Polling',
                  isSelected: selectedIndex == 0,
                  onTap: () => onTabChanged(0),
                ),
              ),
              Expanded(
                child: _buildTab(
                  context: context,
                  label: 'Survei',
                  isSelected: selectedIndex == 1,
                  onTap: () => onTabChanged(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // Tab text
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? colors.primaryBlue : colors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Underline indicator - full width
          Container(
            height: 2.h,
            decoration: BoxDecoration(
              color: isSelected ? colors.primaryBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
        ],
      ),
    );
  }
}
