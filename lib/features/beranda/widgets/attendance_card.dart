import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/core/utils/string_utils.dart';

/// Attendance Card dengan expandable toggle
class AttendanceCard extends StatefulWidget {
  final String shiftInfo;
  final String date;
  final String? jamMasuk;
  final String? jamKeluar;
  final VoidCallback? onRekamWaktuTap;
  final VoidCallback? onLainnyaTap;
  final VoidCallback? onBarcodeTap;
  final VoidCallback? onShiftTap;
  final bool isLoading;
  final String? name;

  const AttendanceCard({
    super.key,
    required this.shiftInfo,
    required this.date,
    this.jamMasuk,
    this.jamKeluar,
    this.onRekamWaktuTap,
    this.onLainnyaTap,
    this.onBarcodeTap,
    this.onShiftTap,
    this.isLoading = false,
    this.name,
  });

  @override
  State<AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header info (selalu tampil)
          _buildHeader(colors),

          Divider(color: colors.divider, thickness: 2.r),
          // Jam masuk & keluar
          _buildTimeInfo(colors),

          // Rekam Waktu button
          _buildRekamWaktuButton(colors),

          // Lainnya button (hanya saat expanded)
          if (_isExpanded) _buildLainnyaButton(colors),

          // Toggle button
          Divider(color: colors.divider, thickness: 2.r),
          _buildToggleButton(colors),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic colors) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.date,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.shiftInfo,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onShiftTap ?? () {},
            icon: Icon(
              Icons.description_outlined,
              color: colors.textSecondary,
              size: 20.sp,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(dynamic colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Jam Masuk
          Expanded(
            child: _buildTimeColumn(
              colors: colors,
              label: 'Jam Masuk',
              time: widget.jamMasuk,
              isCheckIn: true,
            ),
          ),
          Container(height: 40.h, width: 1, color: colors.divider),
          // Jam Keluar
          Expanded(
            child: _buildTimeColumn(
              colors: colors,
              label: 'Jam Keluar',
              time: widget.jamKeluar,
              isCheckIn: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn({
    required dynamic colors,
    required String label,
    required String? time,
    required bool isCheckIn,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          // Avatar/initials
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorPalette.slate200,
              // border: Border.all(color: ColorPalette.orange400, width: 1.5),
            ),
            child: Center(
              child: Text(
                StringUtils.getInitials(widget.name),
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.slate500,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      time ?? '--:--',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.location_on,
                      size: 12.sp,
                      color: isCheckIn
                          ? ColorPalette.green500
                          : ColorPalette.red500,
                    ),
                    Icon(
                      Icons.people,
                      size: 12.sp,
                      color: isCheckIn
                          ? ColorPalette.green500
                          : ColorPalette.red500,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRekamWaktuButton(dynamic colors) {
    final buttonHeight = 36.h; // Tinggi tetap untuk kedua button

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: widget.onRekamWaktuTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Rekam Waktu',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: buttonHeight, // Sama dengan tinggi = persegi
            height: buttonHeight,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: colors.divider),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: IconButton(
                onPressed: widget.onBarcodeTap ?? () {},
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.qr_code_scanner,
                  color: colors.textSecondary,
                  size: 22.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLainnyaButton(dynamic colors) {
    return GestureDetector(
      onTap: widget.onLainnyaTap ?? () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        alignment: Alignment.center,
        child: Text(
          'Lainnya',
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(dynamic colors) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isExpanded ? 'Sembunyikan Detail' : 'Lihat Detail',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: colors.primaryBlue,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: colors.primaryBlue,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
