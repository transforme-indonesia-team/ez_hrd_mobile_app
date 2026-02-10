import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/config/env_config.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/data/models/attendance_employee_model.dart';
import 'package:hrd_app/data/services/attendance_service.dart';
import 'package:intl/intl.dart';

/// Bottom sheet that shows attendance history log for a specific date range.
/// Triggered from "Lihat Log" in the Detail Kehadiran screen.
abstract class AttendanceLogBottomSheet {
  static void show(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          _AttendanceLogContent(startDate: startDate, endDate: endDate),
    );
  }
}

class _AttendanceLogContent extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const _AttendanceLogContent({this.startDate, this.endDate});

  @override
  State<_AttendanceLogContent> createState() => _AttendanceLogContentState();
}

class _AttendanceLogContentState extends State<_AttendanceLogContent> {
  bool _isLoading = true;
  List<_LogRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _fetchLog();
  }

  Future<void> _fetchLog() async {
    try {
      final response = await AttendanceService().getAttendanceHistory(
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      final rawRecords =
          response['original']?['records'] as List<dynamic>? ??
          response['records'] as List<dynamic>? ??
          [];

      final List<_LogRecord> records = [];

      for (final raw in rawRecords) {
        final data = raw as Map<String, dynamic>;
        final model = AttendanceEmployeeModel.fromJson(data);

        if (model.hasCheckIn) {
          records.add(
            _LogRecord(
              isCheckIn: true,
              date: model.dateSchedule,
              time: model.checkIn,
              photo: model.attendancePhotoIn,
              employeeName: model.displayEmployeeName,
              shift: model.displayShift,
            ),
          );
        }

        if (model.hasCheckOut) {
          records.add(
            _LogRecord(
              isCheckIn: false,
              date: model.dateSchedule,
              time: model.checkOut,
              photo: model.attendancePhotoOut,
              employeeName: model.displayEmployeeName,
              shift: model.displayShift,
            ),
          );
        }

        // If absent, add a single absent record
        if (!model.hasCheckIn && !model.hasCheckOut) {
          records.add(
            _LogRecord(
              isCheckIn: true,
              isAbsent: true,
              date: model.dateSchedule,
              time: null,
              photo: null,
              employeeName: model.displayEmployeeName,
              shift: model.displayShift,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _records = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching attendance log: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxHeight = MediaQuery.of(context).size.height * 0.65;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(Icons.history, color: colors.textSecondary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Riwayat Kehadiran',
                  style: AppTextStyles.h4(colors.textPrimary),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: colors.textSecondary,
                    size: 22.sp,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.divider),
          // Content
          Flexible(
            child: _isLoading
                ? _buildSkeleton()
                : _records.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: EmptyStateWidget(),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 16.h,
                    ),
                    itemCount: _records.length,
                    itemBuilder: (context, index) =>
                        _buildLogItem(colors, _records[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return SkeletonContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: List.generate(
            3,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  SkeletonCircle(size: 40),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 60.w, height: 12.h, borderRadius: 4),
                        SizedBox(height: 6.h),
                        SkeletonBox(
                          width: 140.w,
                          height: 14.h,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogItem(ThemeColors colors, _LogRecord record) {
    String formattedDate = record.date ?? '';
    if (record.date != null) {
      try {
        final date = DateTime.parse(record.date!);
        formattedDate = DateFormat('dd MMM yyyy', 'id').format(date);
        if (record.time != null) {
          formattedDate = '$formattedDate ${record.time}';
        }
      } catch (_) {}
    }

    final hasPhoto =
        record.photo != null && record.photo!.isNotEmpty && record.photo != '-';
    final fullPhotoUrl = hasPhoto
        ? '${EnvConfig.imageBaseUrl}${record.photo}'
        : null;

    // Determine colors
    Color borderColor;
    Color badgeColor;
    Color badgeTextColor;
    String badgeLabel;

    if (record.isAbsent) {
      borderColor = ColorPalette.red500;
      badgeColor = ColorPalette.red100;
      badgeTextColor = ColorPalette.red700;
      badgeLabel = 'Tidak Hadir';
    } else if (record.isCheckIn) {
      borderColor = ColorPalette.green500;
      badgeColor = ColorPalette.green100;
      badgeTextColor = ColorPalette.green700;
      badgeLabel = 'Masuk';
    } else {
      borderColor = ColorPalette.blue500;
      badgeColor = ColorPalette.blue100;
      badgeTextColor = ColorPalette.blue700;
      badgeLabel = 'Keluar';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider, width: 1)),
      ),
      child: Row(
        children: [
          // Photo avatar
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorPalette.slate200,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: fullPhotoUrl != null
                ? ClipOval(
                    child: Image.network(
                      fullPhotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: ColorPalette.slate400,
                          size: 20.sp,
                        );
                      },
                    ),
                  )
                : Icon(Icons.person, color: ColorPalette.slate400, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 4.h),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    badgeLabel,
                    style: AppTextStyles.xxSmall(badgeTextColor),
                  ),
                ),
                Text(
                  formattedDate,
                  style: AppTextStyles.smallMedium(colors.textPrimary),
                ),
                if (record.shift != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    record.shift!,
                    style: AppTextStyles.xSmall(colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogRecord {
  final bool isCheckIn;
  final bool isAbsent;
  final String? date;
  final String? time;
  final String? photo;
  final String? employeeName;
  final String? shift;

  _LogRecord({
    required this.isCheckIn,
    this.isAbsent = false,
    this.date,
    this.time,
    this.photo,
    this.employeeName,
    this.shift,
  });
}
