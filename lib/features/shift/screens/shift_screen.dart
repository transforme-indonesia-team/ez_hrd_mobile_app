import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/format_date.dart';

/// Shift screen showing weekly shift schedule
class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getWeekStart(DateTime.now());
  }

  DateTime _getWeekStart(DateTime date) {
    // Get Monday of the week
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getShiftForDay(DateTime date) {
    // Weekend = Shift OFF, weekday = Office Hour
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return 'Shift OFF';
    }
    return 'Shift Office Hour';
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
        title: Text(
          'Shift',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.h),
            // Location info card
            _buildLocationCard(colors),
            SizedBox(height: 16.h),
            // Weekly schedule card
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
          // Lokasi Kerja Hari Ini
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
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  'LOKASI BARU PARKIR',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.divider),
          // Lokasi Kehadiran Default
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2.h,
              children: [
                Text(
                  'Lokasi Kehadiran Default',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  '0 Lokasi',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
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
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Jadwal shift mingguan',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
          // Week navigator
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
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: _nextWeek,
                  icon: Icon(Icons.chevron_right, color: colors.primaryBlue),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // Daily shifts list
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
    final shift = _getShiftForDay(date);

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
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              shift,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
