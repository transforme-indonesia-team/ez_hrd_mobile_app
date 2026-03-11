import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/data/models/attendance_employee_model.dart';
import 'package:hrd_app/data/models/attendance_status_model.dart';
import 'package:hrd_app/data/services/attendance_service.dart';
import 'package:hrd_app/data/services/option_service.dart';
import 'package:hrd_app/features/fitur/kehadiran/screens/detail_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/kehadiran/screens/riwayat_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/kehadiran/widgets/attendance_action_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/kehadiran/widgets/attendance_card.dart';
import 'package:hrd_app/features/fitur/kehadiran/widgets/kehadiran_filter_bottom_sheet.dart';

enum AttendanceFilterType { today, last30Days, absentToday }

class DaftarKehadiranScreen extends StatefulWidget {
  const DaftarKehadiranScreen({super.key});

  @override
  State<DaftarKehadiranScreen> createState() => _DaftarKehadiranScreenState();
}

class _DaftarKehadiranScreenState extends State<DaftarKehadiranScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<AttendanceEmployeeModel> _attendances = [];
  List<AttendanceStatusModel> _statuses = [];

  // Quick filter
  AttendanceFilterType _selectedFilter = AttendanceFilterType.today;

  // Advanced filter state
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterEmployeeSearch;
  bool _showWithoutFaceRecognition = false;
  bool _showWithoutLocation = false;
  bool _showWithoutPhoto = false;

  @override
  void initState() {
    super.initState();
    _fetchStatuses();
    _applyQuickFilter(_selectedFilter);
  }

  Future<void> _fetchStatuses() async {
    try {
      final response = await OptionService().getAttendaceStatus();
      List<dynamic>? records;
      if (response['original'] != null) {
        records = response['original']['records'] as List<dynamic>?;
      } else {
        records = response['records'] as List<dynamic>?;
      }
      if (records != null && mounted) {
        setState(() {
          _statuses = AttendanceStatusModel.fromJsonList(records!);
        });
      }
    } catch (e) {
      debugPrint('Error fetching attendance statuses: $e');
    }
  }

  void _applyQuickFilter(AttendanceFilterType filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      List<dynamic>? recordsRaw;

      switch (_selectedFilter) {
        case AttendanceFilterType.today:
          // Hit API: /attendance/attendance-list?request_type=ALL_TODAY
          final response = await AttendanceService().getAttendanceList(
            requestType: 'ALL_TODAY',
          );
          recordsRaw = _extractItems(response);
          break;

        case AttendanceFilterType.absentToday:
          // Hit API: /attendance/attendance-list?request_type=ABSENT_TODAY
          final response = await AttendanceService().getAttendanceList(
            requestType: 'ABSENT_TODAY',
          );
          recordsRaw = _extractItems(response);
          break;

        case AttendanceFilterType.last30Days:
          // Tetap pakai API lama
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final response = await AttendanceService().getAbsentEmployee(
            startDate:
                _filterStartDate ?? today.subtract(const Duration(days: 30)),
            endDate: _filterEndDate ?? today,
          );
          if (response['original'] != null) {
            recordsRaw = response['original']['records'] as List<dynamic>?;
          } else {
            recordsRaw = response['records'] as List<dynamic>?;
          }
          break;
      }

      if (recordsRaw == null || recordsRaw.isEmpty) {
        setState(() {
          _isLoading = false;
          _attendances = [];
          _errorMessage = null;
        });
        return;
      }

      final attendances = recordsRaw
          .map(
            (e) => AttendanceEmployeeModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();

      setState(() {
        _attendances = attendances;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('Error fetching attendance list: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Terjadi kesalahan saat memuat data';
        });
      }
    }
  }

  /// Extract items dari response /attendance/attendance-list
  /// Response structure: { original: { records: { items: [...] } } }
  List<dynamic>? _extractItems(Map<String, dynamic> response) {
    Map<String, dynamic>? records;
    if (response['original'] != null) {
      records = response['original']['records'] as Map<String, dynamic>?;
    } else {
      records = response['records'] as Map<String, dynamic>?;
    }
    return records?['items'] as List<dynamic>?;
  }

  void _showFilterBottomSheet() {
    KehadiranFilterBottomSheet.show(
      context,
      startDate: _filterStartDate,
      endDate: _filterEndDate,
      employeeSearch: _filterEmployeeSearch,
      showWithoutFaceRecognition: _showWithoutFaceRecognition,
      showWithoutLocation: _showWithoutLocation,
      showWithoutPhoto: _showWithoutPhoto,
      onApply:
          ({
            DateTime? startDate,
            DateTime? endDate,
            String? employeeSearch,
            bool showWithoutFaceRecognition = false,
            bool showWithoutLocation = false,
            bool showWithoutPhoto = false,
          }) {
            setState(() {
              _filterStartDate = startDate;
              _filterEndDate = endDate;
              _filterEmployeeSearch = employeeSearch;
              _showWithoutFaceRecognition = showWithoutFaceRecognition;
              _showWithoutLocation = showWithoutLocation;
              _showWithoutPhoto = showWithoutPhoto;
            });
            _fetchData();
          },
    );
  }

  bool get _hasActiveFilter =>
      _filterEmployeeSearch != null ||
      _showWithoutFaceRecognition ||
      _showWithoutLocation ||
      _showWithoutPhoto;

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
          'Daftar Kehadiran',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: colors.textPrimary),
            onPressed: () {
              // TODO: Show more options menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips row
          _buildFilterChips(colors),

          // Content
          Expanded(child: _buildBody(colors)),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeColors colors) {
    return Container(
      color: colors.background,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Filter icon button
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: _hasActiveFilter
                    ? colors.primaryBlue.withValues(alpha: 0.1)
                    : colors.surface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _hasActiveFilter ? colors.primaryBlue : colors.divider,
                ),
              ),
              child: Icon(
                Icons.filter_alt_outlined,
                color: _hasActiveFilter
                    ? colors.primaryBlue
                    : colors.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Horizontal scrollable chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    colors,
                    'Semua Hari Ini',
                    AttendanceFilterType.today,
                  ),
                  SizedBox(width: 8.w),
                  _buildFilterChip(
                    colors,
                    '30 Hari Terakhirku',
                    AttendanceFilterType.last30Days,
                  ),
                  SizedBox(width: 8.w),
                  _buildFilterChip(
                    colors,
                    'Tidak hadir hari ini',
                    AttendanceFilterType.absentToday,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    ThemeColors colors,
    String label,
    AttendanceFilterType type,
  ) {
    final isSelected = _selectedFilter == type;

    return GestureDetector(
      onTap: () => _applyQuickFilter(type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryBlue : colors.background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? colors.primaryBlue : colors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.small(
            isSelected ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeColors colors) {
    if (_isLoading) {
      return _buildSkeletonLoading(colors);
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: AppTextStyles.body(colors.textSecondary),
        ),
      );
    }

    if (_attendances.isEmpty) {
      return const EmptyStateWidget();
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
        itemCount: _attendances.length,
        itemBuilder: (context, index) {
          final attendance = _attendances[index];
          return AttendanceCard(
            attendance: attendance,
            statuses: _statuses,
            onTap: () => _showCardActionSheet(attendance),
            onMorePressed: () => _showCardActionSheet(attendance),
          );
        },
      ),
    );
  }

  void _showCardActionSheet(AttendanceEmployeeModel attendance) {
    AttendanceActionBottomSheet.show(
      context,
      attendance: attendance,
      onDetailKehadiran: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailKehadiranScreen(attendance: attendance),
          ),
        );
      },
      onRiwayatKehadiran: () {
        DateTime? cardDate;
        if (attendance.dateSchedule != null) {
          try {
            cardDate = DateTime.parse(attendance.dateSchedule!);
          } catch (_) {}
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RiwayatKehadiranScreen(
              attendance: attendance,
              startDate: cardDate,
              endDate: cardDate,
            ),
          ),
        );
      },
      onTampilkan7Hari: () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        setState(() {
          _selectedFilter = AttendanceFilterType.last30Days;
          _filterStartDate = today.subtract(const Duration(days: 7));
          _filterEndDate = today;
        });
        _fetchData();
      },
    );
  }

  Widget _buildSkeletonLoading(ThemeColors colors) {
    return SkeletonContainer(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header skeleton
                SkeletonBox(width: 180.w, height: 16.h, borderRadius: 4),
                SizedBox(height: 16.h),

                // Date skeleton
                SkeletonBox(width: 60.w, height: 12.h, borderRadius: 4),
                SizedBox(height: 8.h),
                SkeletonBox(width: 120.w, height: 14.h, borderRadius: 4),
                SizedBox(height: 16.h),

                // Shift & overtime skeleton
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(
                            width: 40.w,
                            height: 12.h,
                            borderRadius: 4,
                          ),
                          SizedBox(height: 4.h),
                          SkeletonBox(
                            width: 100.w,
                            height: 14.h,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(
                            width: 50.w,
                            height: 12.h,
                            borderRadius: 4,
                          ),
                          SizedBox(height: 4.h),
                          SkeletonBox(
                            width: 60.w,
                            height: 14.h,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Time box skeleton
                SkeletonCard(height: 80, borderRadius: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
