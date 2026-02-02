import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/data/models/leave_employee_model.dart';
import 'package:hrd_app/data/services/leave_service.dart';
import 'package:hrd_app/features/fitur/cuti/screens/form_permintaan_cuti.dart';
import 'package:intl/intl.dart';

class KalenderCutiScreen extends StatefulWidget {
  const KalenderCutiScreen({super.key});

  @override
  State<KalenderCutiScreen> createState() => _KalenderCutiScreenState();
}

class _KalenderCutiScreenState extends State<KalenderCutiScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  DateTime _selectedDate = DateTime.now();
  late DateTime _weekStartDate;

  // Data per tanggal: Map<date_string, List<LeaveEmployeeModel>>
  Map<String, List<LeaveEmployeeModel>> _calendarData = {};

  // Pagination untuk items di tanggal terpilih
  int _currentItemIndex = 0;

  @override
  void initState() {
    super.initState();
    _weekStartDate = _getWeekStartDate(_selectedDate);
    _fetchCalendarData();
  }

  /// Get Sunday of the week for given date
  DateTime _getWeekStartDate(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  /// Format date for API (yyyy-MM-dd)
  String _formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Fetch calendar data for current week
  Future<void> _fetchCalendarData() async {
    setState(() => _isLoading = true);

    try {
      final weekEnd = _weekStartDate.add(const Duration(days: 6));
      final response = await LeaveService().leaveCalender(
        startDate: _formatDateForApi(_weekStartDate),
        endDate: _formatDateForApi(weekEnd),
      );

      final records = response['original']['records'] as List<dynamic>? ?? [];

      final Map<String, List<LeaveEmployeeModel>> data = {};
      for (final record in records) {
        final dateStr = record['date'] as String;
        final items = record['items'] as List<dynamic>? ?? [];
        data[dateStr] = items
            .map((e) => LeaveEmployeeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (mounted) {
        setState(() {
          _calendarData = data;
          _isLoading = false;
          _errorMessage = null;
          _currentItemIndex = 0;
        });
      }
    } catch (e) {
      debugPrint('Error fetching calendar data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Terjadi kesalahan saat memuat data';
        });
      }
    }
  }

  /// Navigate to previous week
  void _previousWeek() {
    setState(() {
      _weekStartDate = _weekStartDate.subtract(const Duration(days: 7));
      _selectedDate = _weekStartDate;
      _currentItemIndex = 0;
    });
    _fetchCalendarData();
  }

  /// Navigate to next week
  void _nextWeek() {
    setState(() {
      _weekStartDate = _weekStartDate.add(const Duration(days: 7));
      _selectedDate = _weekStartDate;
      _currentItemIndex = 0;
    });
    _fetchCalendarData();
  }

  /// Select a date
  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentItemIndex = 0;
    });
  }

  /// Get items for selected date
  List<LeaveEmployeeModel> get _selectedDateItems {
    final dateStr = _formatDateForApi(_selectedDate);
    return _calendarData[dateStr] ?? [];
  }

  /// Get current displayed item
  LeaveEmployeeModel? get _currentItem {
    final items = _selectedDateItems;
    if (items.isEmpty) return null;
    if (_currentItemIndex >= items.length) return items.first;
    return items[_currentItemIndex];
  }

  /// Navigate to previous item
  void _previousItem() {
    if (_currentItemIndex > 0) {
      setState(() => _currentItemIndex--);
    }
  }

  /// Navigate to next item
  void _nextItem() {
    if (_currentItemIndex < _selectedDateItems.length - 1) {
      setState(() => _currentItemIndex++);
    }
  }

  Future<void> _navigateToForm() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const FormPermintaanCutiScreeen(),
      ),
    );

    if (result == true && mounted) {
      _fetchCalendarData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kalendar Cuti',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          _buildCalendarSection(colors),
          Expanded(
            child: _isLoading
                ? _buildSkeletonDetail(colors)
                : _buildDetailSection(colors),
          ),
          if (!_isLoading) _buildPagination(colors),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(colors),
    );
  }

  Widget _buildCalendarSection(ThemeColors colors) {
    return Container(
      color: colors.background,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          // Month header with navigation
          _buildMonthHeader(colors),
          SizedBox(height: 16.h),
          // Day names row
          _buildDayNamesRow(colors),
          SizedBox(height: 8.h),
          // Week dates row
          _buildWeekDatesRow(colors),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(ThemeColors colors) {
    final monthYear = DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(monthYear, style: AppTextStyles.h4(colors.textPrimary)),
          Row(
            children: [
              IconButton(
                onPressed: _previousWeek,
                icon: Icon(
                  Icons.chevron_left,
                  color: colors.textSecondary,
                  size: 28.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: _nextWeek,
                icon: Icon(
                  Icons.chevron_right,
                  color: colors.textSecondary,
                  size: 28.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayNamesRow(ThemeColors colors) {
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          return SizedBox(
            width: 40.w,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(colors.textSecondary),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeekDatesRow(ThemeColors colors) {
    final today = DateTime.now();
    final todayStr = _formatDateForApi(today);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final date = _weekStartDate.add(Duration(days: index));
          final dateStr = _formatDateForApi(date);
          final isSelected = dateStr == _formatDateForApi(_selectedDate);
          final isToday = dateStr == todayStr;
          final hasItems = (_calendarData[dateStr]?.isNotEmpty ?? false);

          return GestureDetector(
            onTap: () => _selectDate(date),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isSelected ? colors.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: AppTextStyles.bodyMedium(
                      isSelected
                          ? Colors.white
                          : isToday
                          ? colors.primaryBlue
                          : colors.textPrimary,
                    ),
                  ),
                  if (hasItems && !isSelected)
                    Container(
                      margin: EdgeInsets.only(top: 2.h),
                      width: 4.w,
                      height: 4.w,
                      decoration: BoxDecoration(
                        color: colors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSkeletonDetail(ThemeColors colors) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: SkeletonContainer(
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonText(width: 200.w, height: 16.h),
              SizedBox(height: 16.h),
              SkeletonText(width: 150.w, height: 14.h),
              SizedBox(height: 12.h),
              SkeletonText(width: 120.w, height: 14.h),
              SizedBox(height: 12.h),
              SkeletonText(width: 100.w, height: 14.h),
              SizedBox(height: 12.h),
              SkeletonText(width: 160.w, height: 14.h),
              SizedBox(height: 12.h),
              SkeletonText(width: 160.w, height: 14.h),
              SizedBox(height: 12.h),
              SkeletonBox(width: 80.w, height: 24.h, borderRadius: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(ThemeColors colors) {
    if (_errorMessage != null) {
      return EmptyStateWidget(
        message: _errorMessage!,
        icon: Icons.error_outline,
        onRetry: _fetchCalendarData,
      );
    }

    final item = _currentItem;
    if (item == null) {
      return EmptyStateWidget(
        message: 'Tidak ada data cuti\npada tanggal ini',
        icon: Icons.calendar_month_outlined,
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(colors, 'Diminta untuk', item.displayEmployeeName),
            SizedBox(height: 12.h),
            _buildDetailRow(colors, 'Jenis Cuti', item.displayLeaveTypeName),
            SizedBox(height: 12.h),
            _buildDetailRow(colors, 'Jenis Cuti Hari', '-'),
            SizedBox(height: 12.h),
            _buildDetailRow(
              colors,
              'Jumlah Hari',
              item.totalDays?.toString() ?? '-',
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              colors,
              'Tanggal Mulai',
              FormatDate.fromString(item.startLeave),
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              colors,
              'Tanggal Berakhir',
              FormatDate.fromString(item.endLeave),
            ),
            SizedBox(height: 12.h),
            _buildStatusRow(colors, item.displayStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeColors colors, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label  ', style: AppTextStyles.bodySemiBold(colors.textPrimary)),
        Expanded(
          child: Text(value, style: AppTextStyles.body(colors.textPrimary)),
        ),
      ],
    );
  }

  Widget _buildStatusRow(ThemeColors colors, String status) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Status  ', style: AppTextStyles.bodySemiBold(colors.textPrimary)),
        _StatusBadge(status: status),
      ],
    );
  }

  Widget _buildPagination(ThemeColors colors) {
    final items = _selectedDateItems;
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: colors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Menampilkan ${items.length} data',
            style: AppTextStyles.caption(colors.textSecondary),
          ),
          if (items.length > 1)
            Row(
              children: [
                IconButton(
                  onPressed: _currentItemIndex > 0 ? _previousItem : null,
                  icon: Icon(
                    Icons.chevron_left,
                    color: _currentItemIndex > 0
                        ? colors.textPrimary
                        : colors.divider,
                    size: 24.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(width: 16.w),
                IconButton(
                  onPressed: _currentItemIndex < items.length - 1
                      ? _nextItem
                      : null,
                  icon: Icon(
                    Icons.chevron_right,
                    color: _currentItemIndex < items.length - 1
                        ? colors.textPrimary
                        : colors.divider,
                    size: 24.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(ThemeColors colors) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: colors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _navigateToForm,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Permintaan Baru',
            style: AppTextStyles.button(Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primaryBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ),
    );
  }
}

/// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusUpper = status.toUpperCase();

    // Convert status to readable format
    String label = status
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');

    final (Color backgroundColor, Color textColor) = switch (statusUpper) {
      'DRAFT' => (const Color(0xFFE0E7FF), const Color(0xFF4338CA)),
      'PENDING' => (const Color(0xFFFFF3CD), const Color(0xFFD68910)),
      _ when statusUpper.contains('WAITING') => (
        const Color(0xFFFFF3CD),
        const Color(0xFFD68910),
      ),
      _ when statusUpper.contains('APPROVE') => (
        const Color(0xFFD4EDDA),
        const Color(0xFF28A745),
      ),
      _ when statusUpper.contains('REJECT') => (
        const Color(0xFFF8D7DA),
        const Color(0xFFDC3545),
      ),
      _ when statusUpper.contains('CANCEL') => (
        const Color(0xFFF8D7DA),
        const Color(0xFFDC3545),
      ),
      _ when statusUpper.contains('UNVERIFIED') => (
        const Color(0xFFFFF3CD),
        const Color(0xFFD68910),
      ),
      _ => (colors.divider, colors.textSecondary),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(textColor),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
