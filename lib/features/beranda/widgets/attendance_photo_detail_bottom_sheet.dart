import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/core/utils/image_url_extension.dart';
import 'package:hrd_app/features/beranda/widgets/attendance_location_bottom_sheet.dart';

class AttendancePhotoDetailBottomSheet extends StatelessWidget {
  final String photoUrl;
  final String date;
  final String time;
  final bool isCheckIn;
  final String? employeeId;

  const AttendancePhotoDetailBottomSheet({
    super.key,
    required this.photoUrl,
    required this.date,
    required this.time,
    this.isCheckIn = true,
    this.employeeId,
  });

  static void show({
    required BuildContext context,
    required String photoUrl,
    required String date,
    required String time,
    bool isCheckIn = true,
    String? employeeId,
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
        employeeId: employeeId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10.h, bottom: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Content: Photo left, Info right
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        photoUrl.asFullImageUrl ?? photoUrl,
                        width: 120.w,
                        height: 160.h,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 120.w,
                            height: 160.h,
                            color: colors.surface,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: colors.primaryBlue,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120.w,
                            height: 160.h,
                            decoration: BoxDecoration(
                              color: ColorPalette.slate200,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: ColorPalette.slate400,
                              size: 40.sp,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date
                          Text(
                            date,
                            style: AppTextStyles.bodyMedium(colors.textPrimary),
                          ),
                          SizedBox(height: 6.h),

                          // Time + icons
                          Row(
                            children: [
                              Text(
                                time,
                                style: AppTextStyles.h4(
                                  isCheckIn
                                      ? ColorPalette.green500
                                      : ColorPalette.red500,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              // Location icon - tappable
                              GestureDetector(
                                onTap: () => _openLocationSheet(context),
                                child: Icon(
                                  Icons.location_on,
                                  size: 16.sp,
                                  color: isCheckIn
                                      ? ColorPalette.green500
                                      : ColorPalette.red500,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.people,
                                size: 16.sp,
                                color: isCheckIn
                                    ? ColorPalette.green500
                                    : ColorPalette.red500,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          // Status
                          Text(
                            'Status',
                            style: AppTextStyles.small(colors.textSecondary),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: ColorPalette.green100,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Telah diproses',
                              style: AppTextStyles.xSmallMedium(
                                ColorPalette.green700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openLocationSheet(BuildContext context) {
    // Close current bottom sheet first
    Navigator.pop(context);

    // Open location bottom sheet
    AttendanceLocationBottomSheet.show(
      context: context,
      employeeId: employeeId,
      date: DateTime.now(),
      type: isCheckIn ? 'CHECK_IN' : 'CHECK_OUT',
    );
  }
}
