import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';
import 'package:hrd_app/data/models/schedule_shift_employee_model.dart';
import 'package:hrd_app/data/services/attendance_service.dart';
import 'package:hrd_app/features/fitur/jadwal_shift/widgets/employee_picker_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/jadwal_shift/widgets/jadwal_shift_filter_bottom_sheet.dart';
import 'package:provider/provider.dart';

class JadwalShiftScreen extends StatefulWidget {
  const JadwalShiftScreen({super.key});

  @override
  State<JadwalShiftScreen> createState() => _JadwalShiftScreenState();
}

class _JadwalShiftScreenState extends State<JadwalShiftScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<ScheduleShiftEmployeeModel> _employees = [];

  // Filter state
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  List<EmployeeMemberItem> _selectedEmployees = [];

  // Data dari user login
  String? _currentEmployeeId;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _currentEmployeeId = user?.employeeId;

    // Default: 7 hari mulai dari hari ini
    final now = DateTime.now();
    _filterStartDate = DateTime(now.year, now.month, now.day);
    _filterEndDate = _filterStartDate!.add(const Duration(days: 6));

    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Build employee_id list untuk API
      List<Map<String, dynamic>> employeeIds = [];

      if (_selectedEmployees.isNotEmpty) {
        employeeIds = _selectedEmployees
            .map((e) => {'employee_id': e.value})
            .toList();
      } else if (_currentEmployeeId != null) {
        employeeIds = [
          {'employee_id': _currentEmployeeId},
        ];
      }

      final response = await AttendanceService().getScheduleByEmployee(
        employeeId: employeeIds,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
      );

      List<dynamic>? recordsRaw;
      if (response['original'] != null) {
        recordsRaw = response['original']['records'] as List<dynamic>?;
      } else {
        recordsRaw = response['records'] as List<dynamic>?;
      }

      if (recordsRaw == null || recordsRaw.isEmpty) {
        setState(() {
          _isLoading = false;
          _employees = [];
        });
        return;
      }

      setState(() {
        _employees = recordsRaw!
            .map(
              (e) => ScheduleShiftEmployeeModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('JadwalShift: Error fetching data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _showFilterBottomSheet() {
    JadwalShiftFilterBottomSheet.show(
      context,
      startDate: _filterStartDate,
      endDate: _filterEndDate,
      selectedEmployees: _selectedEmployees,
      employeeId: _currentEmployeeId,
      onApply:
          ({
            DateTime? startDate,
            DateTime? endDate,
            List<EmployeeMemberItem> selectedEmployees = const [],
          }) {
            setState(() {
              _filterStartDate = startDate;
              _filterEndDate = endDate;
              _selectedEmployees = selectedEmployees;
            });
            _fetchData();
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.backgroundDetail,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Jadwal Shift',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt_outlined,
              color: _selectedEmployees.isNotEmpty
                  ? colors.primaryBlue
                  : colors.textPrimary,
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(colors)),
          _buildBottomButton(colors),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeColors colors) {
    if (_isLoading) {
      return _buildSkeletonLoading(colors);
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                style: AppTextStyles.body(colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: _fetchData,
                child: Text(
                  'Coba Lagi',
                  style: AppTextStyles.bodyMedium(colors.primaryBlue),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_employees.isEmpty) {
      return const EmptyStateWidget(
        message: 'Tidak ada jadwal shift',
        icon: Icons.calendar_month,
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          return _buildEmployeeCard(_employees[index], colors);
        },
      ),
    );
  }

  Widget _buildEmployeeCard(
    ScheduleShiftEmployeeModel employee,
    ThemeColors colors,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee header
            Row(
              children: [
                UserAvatar(
                  name: employee.employeeName,
                  avatarUrl: employee.profile,
                  size: 40,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.employeeName ?? '-',
                        style: AppTextStyles.bodyMedium(colors.textPrimary),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        employee.displayTotalHours,
                        style: AppTextStyles.caption(colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),
            Divider(color: colors.divider, height: 1),

            // Shift days
            ...employee.shifts.asMap().entries.map((entry) {
              final isLast = entry.key == employee.shifts.length - 1;
              return _buildShiftDayRow(entry.value, colors, isLast: isLast);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftDayRow(
    ScheduleShiftDay day,
    ThemeColors colors, {
    bool isLast = false,
  }) {
    // Parse date
    DateTime? dateObj;
    if (day.date != null) {
      try {
        dateObj = DateTime.parse(day.date!);
      } catch (_) {}
    }

    final dateDisplay = dateObj != null
        ? FormatDate.todayWithDayName(dateObj)
        : (day.date ?? '-');

    final shiftName = day.shiftData.isNotEmpty
        ? day.shiftData.first.shiftName ?? '-'
        : '-';
    final shiftTime = day.shiftData.isNotEmpty
        ? day.shiftData.first.time ?? '-'
        : '-';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: colors.divider.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: date + shift info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateDisplay,
                  style: AppTextStyles.bodyMedium(colors.textPrimary),
                ),
                SizedBox(height: 4.h),
                Text(
                  shiftName,
                  style: AppTextStyles.small(colors.textSecondary),
                ),
                Text(
                  shiftTime,
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
              ],
            ),
          ),
          // Right: hours
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Text(
              day.displayHours,
              style: AppTextStyles.bodyMedium(colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(ThemeColors colors) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        MediaQuery.of(context).padding.bottom + 12.h,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            context.showInfoSnackbar('Fitur "Ambil Shift" belum tersedia');
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.primaryBlue,
            side: BorderSide(color: colors.primaryBlue),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'Ambil Shift',
            style: AppTextStyles.button(colors.primaryBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading(ThemeColors colors) {
    return SkeletonContainer(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 40.w, height: 40.w, borderRadius: 20),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(
                          width: 160.w,
                          height: 14.h,
                          borderRadius: 4,
                        ),
                        SizedBox(height: 6.h),
                        SkeletonBox(
                          width: 100.w,
                          height: 12.h,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                for (int i = 0; i < 5; i++) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(
                            width: 120.w,
                            height: 14.h,
                            borderRadius: 4,
                          ),
                          SizedBox(height: 4.h),
                          SkeletonBox(
                            width: 80.w,
                            height: 12.h,
                            borderRadius: 4,
                          ),
                          SizedBox(height: 4.h),
                          SkeletonBox(
                            width: 60.w,
                            height: 10.h,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                      SkeletonBox(width: 50.w, height: 14.h, borderRadius: 4),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
