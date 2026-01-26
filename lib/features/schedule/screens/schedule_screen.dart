import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/data/models/schedule_shift_model.dart';
import 'package:hrd_app/data/services/attendance_service.dart';
import 'package:provider/provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _currentWeekStart;
  bool _isLoading = true;
  List<ScheduleShiftModel> _shifts = [];

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getWeekStart(DateTime.now());
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    final authProvider = context.read<AuthProvider>();
    final employeeId = authProvider.user?.employeeId ?? '';

    if (employeeId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final startDate = _currentWeekStart;
    final endDate = _currentWeekStart.add(const Duration(days: 6));
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await AttendanceService().getSchedule(
        employeeId: employeeId,
        startDate: startDate,
        endDate: endDate,
      );

      final original = response['original'] as Map<String, dynamic>?;
      if (original?['status'] == true && original?['records'] != null) {
        final records = original!['records'] as Map<String, dynamic>;
        final shiftsJson = records['shifts'] as List<dynamic>? ?? [];
        setState(() {
          _shifts = shiftsJson
              .map(
                (e) => ScheduleShiftModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Schedule Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
    _fetchSchedule();
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
    _fetchSchedule();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  ScheduleShiftModel? _getShiftForDay(DateTime date) {
    final dateStr = FormatDate.apiFormat(date);
    return _shifts.firstWhereOrNull((shift) => shift.date == dateStr);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Shift', style: AppTextStyles.h3(colors.textPrimary)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.h),
            _buildLocationCard(colors),
            SizedBox(height: 16.h),
            _buildWeeklyScheduleCard(colors, weekEnd),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(dynamic colors) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: colors.primaryBlue, width: 4.w),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4.h,
              children: [
                Text(
                  'Lokasi Kerja Hari Ini',
                  style: AppTextStyles.body(colors.textSecondary),
                ),
                Text(
                  'LOKASI BARU PARKIR',
                  style: AppTextStyles.bodySemiBold(colors.textPrimary),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.divider),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleCard(dynamic colors, DateTime weekEnd) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Jadwal shift mingguan',
              style: AppTextStyles.bodyLarge(colors.textPrimary),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousWeek,
                  icon: Icon(Icons.chevron_left, color: colors.textSecondary),
                ),
                Text(
                  FormatDate.dateRange(_currentWeekStart, weekEnd),
                  style: AppTextStyles.captionMedium(colors.textPrimary),
                ),
                IconButton(
                  onPressed: _nextWeek,
                  icon: Icon(Icons.chevron_right, color: colors.primaryBlue),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          if (_isLoading)
            ...List.generate(7, (index) => _buildShiftItemSkeleton(colors))
          else
            ...List.generate(7, (index) {
              final date = _currentWeekStart.add(Duration(days: index));
              return _buildShiftItem(colors, date);
            }),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildShiftItem(dynamic colors, DateTime date) {
    final isToday = _isToday(date);
    final schedule = _getShiftForDay(date);

    final shiftName = schedule?.displayShiftName ?? 'Tidak ada jadwal';
    final shiftTime = schedule?.displayTime ?? '-';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isToday ? colors.primaryBlue : Colors.transparent,
            width: 3.w,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isToday
              ? colors.primaryBlue.withValues(alpha: 0.05)
              : colors.background,
          border: Border.all(
            color: isToday
                ? colors.primaryBlue.withValues(alpha: 0.2)
                : colors.divider,
          ),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8.r),
            bottomRight: Radius.circular(8.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FormatDate.dayWithFullDate(date),
              style: AppTextStyles.body(colors.textSecondary),
            ),
            SizedBox(height: 5.h),
            Row(
              spacing: 8.w,
              children: [
                Text(
                  shiftName,
                  style: AppTextStyles.bodyMedium(colors.textPrimary),
                ),
                Text(
                  "[$shiftTime]",
                  style: AppTextStyles.bodyMedium(colors.textPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftItemSkeleton(dynamic colors) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: colors.divider),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: SkeletonContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 150.w, height: 14.h),
              SizedBox(height: 4.h),
              SkeletonBox(width: 100.w, height: 12.h),
              SizedBox(height: 2.h),
              SkeletonBox(width: 80.w, height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
