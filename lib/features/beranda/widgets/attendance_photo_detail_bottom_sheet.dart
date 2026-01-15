import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/config/env_config.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/color_palette.dart';

/// Bottom sheet untuk menampilkan detail foto attendance
class AttendancePhotoDetailBottomSheet extends StatelessWidget {
  final String photoUrl;
  final String date;
  final String time;
  final bool isCheckIn;

  const AttendancePhotoDetailBottomSheet({
    super.key,
    required this.photoUrl,
    required this.date,
    required this.time,
    this.isCheckIn = true,
  });

  static void show({
    required BuildContext context,
    required String photoUrl,
    required String date,
    required String time,
    bool isCheckIn = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttendancePhotoDetailBottomSheet(
        photoUrl: photoUrl,
        date: date,
        time: time,
        isCheckIn: isCheckIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context, colors),

          // Photo
          Expanded(child: _buildPhoto(colors)),

          // Info section
          _buildInfoSection(colors),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic colors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isCheckIn ? 'Kam, $date' : 'Rab, $date',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: colors.textSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto(dynamic colors) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          '${EnvConfig.imageBaseUrl}$photoUrl',
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: colors.primaryBlue,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 64.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Gagal memuat foto',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoSection(dynamic colors) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.divider, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time and icons
          Row(
            children: [
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.green500,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.location_on,
                size: 16.sp,
                color: ColorPalette.green500,
              ),
              SizedBox(width: 4.w),
              Icon(Icons.camera_alt, size: 16.sp, color: ColorPalette.green500),
            ],
          ),
          SizedBox(height: 12.h),

          // Status
          Row(
            children: [
              Text(
                'Status',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ColorPalette.green100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Telah diproses',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: ColorPalette.green700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
