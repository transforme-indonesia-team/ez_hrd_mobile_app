import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/core/utils/image_url_extension.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';
import 'package:hrd_app/features/beranda/widgets/attendance_photo_detail_bottom_sheet.dart';

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
  final String? avatarUrl;
  final String? photoIn;
  final String? photoOut;

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
    this.avatarUrl,
    this.photoIn,
    this.photoOut,
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
          _buildHeader(colors),

          Divider(color: colors.divider, thickness: 2.r),
          _buildTimeInfo(colors),

          _buildRekamWaktuButton(colors),

          if (_isExpanded) ...[
            _buildAttendancePhotoList(colors),

            _buildLainnyaButton(colors),
          ],

          Divider(color: colors.divider, thickness: 2.r),
          _buildToggleButton(colors),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeColors colors) {
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
                  style: AppTextStyles.xSmall(colors.textSecondary),
                ),
                SizedBox(height: 4.h),
                if (widget.isLoading)
                  _buildShiftSkeleton()
                else
                  Text(
                    widget.shiftInfo,
                    style: AppTextStyles.captionMedium(colors.textPrimary),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onShiftTap,
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

  Widget _buildShiftSkeleton() {
    return SkeletonContainer(
      child: SkeletonBox(width: 180.w, height: 14.h),
    );
  }

  Widget _buildTimeInfo(ThemeColors colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeColumn(
              colors: colors,
              label: 'Jam Masuk',
              time: widget.jamMasuk,
              attendancePhoto: widget.photoIn,
              isCheckIn: true,
            ),
          ),
          Container(height: 40.h, width: 1, color: colors.divider),
          Expanded(
            child: _buildTimeColumn(
              colors: colors,
              label: 'Jam Keluar',
              time: widget.jamKeluar,
              attendancePhoto: widget.photoOut,
              isCheckIn: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn({
    required ThemeColors colors,
    required String label,
    required String? time,
    required String? attendancePhoto,
    required bool isCheckIn,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          attendancePhoto != null
              ? Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCheckIn
                          ? ColorPalette.green500
                          : ColorPalette.red500,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      attendancePhoto.asFullImageUrl ?? attendancePhoto,
                      width: 32.w,
                      height: 32.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return UserAvatar(
                          avatarUrl: widget.avatarUrl,
                          name: widget.name,
                          size: 32,
                          fontSize: 10,
                        );
                      },
                    ),
                  ),
                )
              : UserAvatar(
                  avatarUrl: widget.avatarUrl,
                  name: widget.name,
                  size: 32,
                  fontSize: 10,
                ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.xSmall(colors.textSecondary)),
                Row(
                  children: [
                    Text(
                      time ?? '--:--',
                      style: AppTextStyles.captionMedium(colors.textSecondary),
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

  Widget _buildRekamWaktuButton(ThemeColors colors) {
    final buttonHeight = 36.h;

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
                  style: AppTextStyles.bodySemiBold(Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: buttonHeight,
            height: buttonHeight,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: colors.divider),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: IconButton(
                onPressed: widget.onBarcodeTap,
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

  Widget _buildLainnyaButton(ThemeColors colors) {
    return GestureDetector(
      onTap: widget.onLainnyaTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        alignment: Alignment.center,
        child: Text(
          'Lainnya',
          style: AppTextStyles.smallMedium(colors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildToggleButton(ThemeColors colors) {
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
              style: AppTextStyles.smallMedium(colors.primaryBlue),
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

  Widget _buildAttendancePhotoList(ThemeColors colors) {
    final List<Map<String, dynamic>> photos = [];

    if (widget.photoIn != null && widget.jamMasuk != null) {
      photos.add({
        'photo': widget.photoIn!,
        'date': widget.date,
        'time': widget.jamMasuk!,
        'isCheckIn': true,
      });
    }

    if (widget.photoOut != null && widget.jamKeluar != null) {
      photos.add({
        'photo': widget.photoOut!,
        'date': widget.date,
        'time': widget.jamKeluar!,
        'isCheckIn': false,
      });
    }

    if (photos.isEmpty) return const SizedBox.shrink();

    return Column(
      children: photos.map((photoData) {
        return _buildAttendancePhotoItem(
          colors: colors,
          photoUrl: photoData['photo'],
          date: photoData['date'],
          time: photoData['time'],
          isCheckIn: photoData['isCheckIn'],
        );
      }).toList(),
    );
  }

  Widget _buildAttendancePhotoItem({
    required ThemeColors colors,
    required String photoUrl,
    required String date,
    required String time,
    required bool isCheckIn,
  }) {
    return InkWell(
      onTap: () {
        AttendancePhotoDetailBottomSheet.show(
          context: context,
          photoUrl: photoUrl,
          date: date,
          time: time,
          isCheckIn: isCheckIn,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.divider, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCheckIn
                      ? ColorPalette.green500
                      : ColorPalette.red500,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  photoUrl.asFullImageUrl ?? photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: ColorPalette.slate200,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: ColorPalette.slate400,
                        size: 24.sp,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: AppTextStyles.smallMedium(colors.textPrimary),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        time,
                        style: AppTextStyles.captionMedium(
                          ColorPalette.green500,
                        ),
                      ),
                      SizedBox(width: 6.w),
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: ColorPalette.green100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Telah diproses',
                style: AppTextStyles.xxSmall(ColorPalette.green700),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, color: colors.textSecondary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
