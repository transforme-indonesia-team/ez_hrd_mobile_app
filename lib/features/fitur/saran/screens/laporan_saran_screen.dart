import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/features/fitur/widgets/laporan_unduh_bottom_sheet.dart';

class LaporanSaranScreen extends StatefulWidget {
  const LaporanSaranScreen({super.key});

  @override
  State<LaporanSaranScreen> createState() => _LaporanSaranScreenState();
}

class _LaporanSaranScreenState extends State<LaporanSaranScreen> {
  Widget _buildLabel(ThemeColors colors, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: AppTextStyles.smallMedium(colors.textSecondary).copyWith(fontSize: 12.sp),
      ),
    );
  }

  Widget _buildFieldContainer(
    ThemeColors colors, {
    required String text,
    IconData? iconData,
    bool isPlaceholder = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isPlaceholder
                  ? AppTextStyles.body(colors.textSecondary).copyWith(fontSize: 13.sp)
                  : AppTextStyles.body(colors.textPrimary).copyWith(fontSize: 13.sp),
            ),
          ),
          if (iconData != null) ...[
            SizedBox(width: 8.w),
            Icon(iconData, color: colors.textSecondary, size: 20.sp),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Laporan Saran',
          style: AppTextStyles.h4(colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Karyawan
            _buildLabel(colors, 'Karyawan'),
            GestureDetector(
              onTap: () {},
              child: _buildFieldContainer(
                colors,
                text: 'Pilih Karyawan',
                iconData: Icons.people_outline,
                isPlaceholder: true,
              ),
            ),
            SizedBox(height: 16.h),

            // Rentang Tanggal
            _buildLabel(colors, 'Rentang Tanggal'),
            GestureDetector(
              onTap: () {},
              child: _buildFieldContainer(
                colors,
                text: '01 Mar 2026 - 31 Mar 2026',
                iconData: Icons.calendar_today_outlined,
                isPlaceholder: false,
              ),
            ),
            SizedBox(height: 24.h),

            // Unduh Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => LaporanActionHelper.showUnduhOptions(context, colors),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primaryBlue, // STRICTLY PRIMARY BLUE
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Unduh',
                      style: AppTextStyles.button(Colors.white).copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20.sp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
