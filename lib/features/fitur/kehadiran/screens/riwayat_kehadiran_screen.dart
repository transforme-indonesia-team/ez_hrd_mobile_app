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

class RiwayatKehadiranScreen extends StatefulWidget {
  final AttendanceEmployeeModel? attendance;
  final String? employeeId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? title;

  const RiwayatKehadiranScreen({
    super.key,
    this.attendance,
    this.employeeId,
    this.startDate,
    this.endDate,
    this.title,
  });

  @override
  State<RiwayatKehadiranScreen> createState() => _RiwayatKehadiranScreenState();
}

class _RiwayatKehadiranScreenState extends State<RiwayatKehadiranScreen> {
  int _selectedTab = 0;
  bool _isLoading = false;
  List<_AttendanceRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    setState(() => _isLoading = true);

    try {
      final response = await AttendanceService().getAttendanceHistory(
        startDate: widget.startDate,
        endDate: widget.endDate,
      );
      final rawRecords =
          response['original']?['records'] as List<dynamic>? ??
          response['records'] as List<dynamic>? ??
          [];

      final List<_AttendanceRecord> records = [];

      for (final raw in rawRecords) {
        final data = raw as Map<String, dynamic>;
        final model = AttendanceEmployeeModel.fromJson(data);

        if (model.hasCheckIn || model.hasCheckOut) {
          // Has attendance data - split into check-in and check-out records
          if (model.hasCheckIn) {
            records.add(
              _AttendanceRecord(
                type: _RecordType.checkIn,
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
              _AttendanceRecord(
                type: _RecordType.checkOut,
                date: model.dateSchedule,
                time: model.checkOut,
                photo: model.attendancePhotoOut,
                employeeName: model.displayEmployeeName,
                shift: model.displayShift,
              ),
            );
          }
        } else {
          // No check-in and no check-out: absent
          records.add(
            _AttendanceRecord(
              type: _RecordType.absent,
              date: model.dateSchedule,
              time: null,
              photo: null,
              employeeName: model.displayEmployeeName,
              shift: model.displayShift,
            ),
          );
        }
      }

      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching riwayat: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title ?? 'Riwayat Kehadiran',
          style: AppTextStyles.h4(colors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          _buildTabSection(colors),
          Expanded(
            child: _isLoading
                ? _buildSkeleton()
                : _selectedTab == 1
                ? const EmptyStateWidget()
                : _records.isEmpty
                ? const EmptyStateWidget()
                : _buildAttendanceList(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(ThemeColors colors) {
    return Container(
      color: colors.background,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          SizedBox(height: 12.h),
          Text(
            _selectedTab == 0
                ? 'Meninjau riwayat kehadiran Anda secara mendetail'
                : 'Riwayat kehadiran rekan kerja Anda yang direkam menggunakan perangkat Anda',
            style: AppTextStyles.caption(colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required ThemeColors colors,
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
          style: AppTextStyles.smallMedium(
            isSelected ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return SkeletonContainer(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: SkeletonCard(height: 80.h),
        ),
      ),
    );
  }

  Widget _buildAttendanceList(ThemeColors colors) {
    return RefreshIndicator(
      onRefresh: _fetchRiwayat,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _records.length,
        itemBuilder: (context, index) {
          return _buildAttendanceItem(colors, _records[index]);
        },
      ),
    );
  }

  Widget _buildAttendanceItem(ThemeColors colors, _AttendanceRecord record) {
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

    // Determine colors based on record type
    Color borderColor;
    Color badgeColor;
    Color badgeTextColor;
    String badgeLabel;

    switch (record.type) {
      case _RecordType.checkIn:
        borderColor = ColorPalette.green500;
        badgeColor = ColorPalette.green100;
        badgeTextColor = ColorPalette.green700;
        badgeLabel = 'Masuk';
        break;
      case _RecordType.checkOut:
        borderColor = ColorPalette.blue500;
        badgeColor = ColorPalette.blue100;
        badgeTextColor = ColorPalette.blue700;
        badgeLabel = 'Keluar';
        break;
      case _RecordType.absent:
        borderColor = ColorPalette.red500;
        badgeColor = ColorPalette.red100;
        badgeTextColor = ColorPalette.red700;
        badgeLabel = 'Tidak Hadir';
        break;
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
            width: 48.w,
            height: 48.w,
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
                          size: 24.sp,
                        );
                      },
                    ),
                  )
                : Icon(Icons.person, color: ColorPalette.slate400, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
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
                // Date + Time
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
                SizedBox(height: 4.h),
                if (record.type != _RecordType.absent) ...[
                  // Status processed
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
                        style: AppTextStyles.xSmall(ColorPalette.green500),
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
                        color: hasPhoto
                            ? ColorPalette.green500
                            : ColorPalette.red500,
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        size: 14.sp,
                        color: ColorPalette.red500,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Belum absen',
                        style: AppTextStyles.xSmall(ColorPalette.red500),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (record.type != _RecordType.absent)
            Icon(
              Icons.location_on_outlined,
              color: ColorPalette.orange400,
              size: 24.sp,
            ),
        ],
      ),
    );
  }
}

enum _RecordType { checkIn, checkOut, absent }

/// Internal model to represent a single attendance record
class _AttendanceRecord {
  final _RecordType type;
  final String? date;
  final String? time;
  final String? photo;
  final String? employeeName;
  final String? shift;

  _AttendanceRecord({
    required this.type,
    this.date,
    this.time,
    this.photo,
    this.employeeName,
    this.shift,
  });
}
