import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/config/env_config.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:intl/intl.dart';

/// Bottom sheet untuk menampilkan Riwayat Kehadiran
class RiwayatKehadiranBottomSheet extends StatefulWidget {
  const RiwayatKehadiranBottomSheet({super.key});

  static void show(
    BuildContext context, {
    List<Map<String, dynamic>>? records,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.7,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _RiwayatKehadiranContent(
            scrollController: scrollController,
            records: records ?? [],
          );
        },
      ),
    );
  }

  @override
  State<RiwayatKehadiranBottomSheet> createState() =>
      _RiwayatKehadiranBottomSheetState();
}

class _RiwayatKehadiranBottomSheetState
    extends State<RiwayatKehadiranBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _RiwayatKehadiranContent extends StatefulWidget {
  final ScrollController scrollController;
  final List<Map<String, dynamic>> records;

  const _RiwayatKehadiranContent({
    required this.scrollController,
    required this.records,
  });

  @override
  State<_RiwayatKehadiranContent> createState() =>
      _RiwayatKehadiranContentState();
}

class _RiwayatKehadiranContentState extends State<_RiwayatKehadiranContent> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(colors),
          // Content
          Expanded(
            child: _selectedTab == 1
                ? _buildEmptyState(colors) // Kehadiran Bersama = always empty
                : widget.records.isEmpty
                ? _buildEmptyState(colors)
                : _buildAttendanceList(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title bar with background
        Container(
          decoration: BoxDecoration(
            color: ColorPalette.slate200,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Text(
                  'Riwayat Kehadiran',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Toggle buttons (no background)
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          child: Row(
            children: [
              _buildTabButton(
                colors: colors,
                label: 'Kehadiran Saya',
                isSelected: _selectedTab == 0,
                onTap: () => setState(() => _selectedTab = 0),
              ),
              SizedBox(width: 8.w),
              _buildTabButton(
                colors: colors,
                label: 'Kehadiran Bersama',
                isSelected: _selectedTab == 1,
                onTap: () => setState(() => _selectedTab = 1),
              ),
            ],
          ),
        ),
        // Description text
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Text(
            _selectedTab == 0
                ? 'Meninjau riwayat kehadiran Anda secara mendetail'
                : 'Riwayat kehadiran rekan kerja Anda yang direkam menggunakan perangkat Anda',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required dynamic colors,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? colors.primaryBlue : colors.divider,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceList(dynamic colors) {
    return ListView.builder(
      controller: widget.scrollController,
      padding: EdgeInsets.zero,
      itemCount: widget.records.length,
      itemBuilder: (context, index) {
        final record = widget.records[index];
        return _buildAttendanceItem(colors, record);
      },
    );
  }

  Widget _buildAttendanceItem(dynamic colors, Map<String, dynamic> record) {
    final dateStr = record['date_schedule'] as String?;
    final time = record['time'] as String?;
    final photo = record['photo'] as String?;
    final type = record['type'] as String?;
    final isCheckIn = type == 'check_in';

    // Format date
    String formattedDate = dateStr ?? '';
    if (dateStr != null) {
      try {
        final date = DateTime.parse(dateStr);
        formattedDate = DateFormat('dd MMM yyyy', 'id').format(date);
        if (time != null) {
          formattedDate = '$formattedDate $time';
        }
      } catch (_) {}
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider, width: 1)),
      ),
      child: Row(
        children: [
          // Photo
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorPalette.slate200,
            ),
            child: photo != null && photo != '-'
                ? ClipOval(
                    child: Image.network(
                      '${EnvConfig.imageBaseUrl}$photo',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: ColorPalette.slate400,
                          size: 24.sp,
                        );
                      },
                    ),
                  )
                : Icon(Icons.person, color: ColorPalette.slate400, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.check,
                      size: 14.sp,
                      color: ColorPalette.green500,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Telah diproses',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: ColorPalette.green500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.phone_android,
                      size: 14.sp,
                      color: ColorPalette.green500,
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.location_on,
                      size: 14.sp,
                      color: ColorPalette.green500,
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.camera_alt,
                      size: 14.sp,
                      color: ColorPalette.green500,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Location icon
          Icon(
            Icons.location_on_outlined,
            color: ColorPalette.orange400,
            size: 24.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(dynamic colors) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon document
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.description_outlined,
              size: 48.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24.h),
          // Title
          Text(
            'Tidak ada data untuk\nditampilkan',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
