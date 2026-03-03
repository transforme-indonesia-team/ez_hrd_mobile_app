import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/features/fitur/jadwal_shift/widgets/employee_picker_bottom_sheet.dart';

class JadwalShiftFilterBottomSheet extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<EmployeeMemberItem> selectedEmployees;
  final String? employeeId;
  final void Function({
    DateTime? startDate,
    DateTime? endDate,
    List<EmployeeMemberItem> selectedEmployees,
  })
  onApply;

  const JadwalShiftFilterBottomSheet({
    super.key,
    this.startDate,
    this.endDate,
    this.selectedEmployees = const [],
    this.employeeId,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
    List<EmployeeMemberItem> selectedEmployees = const [],
    String? employeeId,
    required void Function({
      DateTime? startDate,
      DateTime? endDate,
      List<EmployeeMemberItem> selectedEmployees,
    })
    onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return JadwalShiftFilterBottomSheet(
            startDate: startDate,
            endDate: endDate,
            selectedEmployees: selectedEmployees,
            employeeId: employeeId,
            onApply: onApply,
          );
        },
      ),
    );
  }

  @override
  State<JadwalShiftFilterBottomSheet> createState() =>
      _JadwalShiftFilterBottomSheetState();
}

class _JadwalShiftFilterBottomSheetState
    extends State<JadwalShiftFilterBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<EmployeeMemberItem> _selectedEmployees = [];

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _selectedEmployees = List.from(widget.selectedEmployees);
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedEmployees.clear();
    });
  }

  Future<void> _selectDateRange() async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now(),
      end: _endDate ?? DateTime.now().add(const Duration(days: 6)),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: (_startDate != null && _endDate != null)
          ? initialDateRange
          : null,
      helpText: 'Pilih Rentang Tanggal',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      saveText: 'Simpan',
      fieldStartLabelText: 'Tanggal Mulai',
      fieldEndLabelText: 'Tanggal Selesai',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _openEmployeePicker() async {
    final result = await EmployeePickerBottomSheet.show(
      context,
      selectedEmployees: _selectedEmployees,
      employeeId: widget.employeeId,
    );

    if (result != null) {
      setState(() {
        _selectedEmployees = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sortir', style: AppTextStyles.h4(colors.textPrimary)),
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'Hapus',
                  style: AppTextStyles.bodyMedium(colors.primaryBlue),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),

          // Karyawan
          Text('Karyawan', style: AppTextStyles.body(colors.textSecondary)),
          SizedBox(height: 8.h),
          _buildEmployeeField(colors),
          SizedBox(height: 16.h),

          // Rentang Tanggal
          Text(
            'Rentang Tanggal',
            style: AppTextStyles.body(colors.textSecondary),
          ),
          SizedBox(height: 8.h),
          _buildDateRangeField(colors),
          SizedBox(height: 24.h),

          // Terapkan button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  startDate: _startDate,
                  endDate: _endDate,
                  selectedEmployees: _selectedEmployees,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Terapkan',
                style: AppTextStyles.button(Colors.white),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
        ],
      ),
    );
  }

  Widget _buildEmployeeField(ThemeColors colors) {
    final hasValue = _selectedEmployees.isNotEmpty;
    final displayText = hasValue
        ? _selectedEmployees.map((e) => e.label).join(', ')
        : 'Pilih Karyawan';

    return GestureDetector(
      onTap: _openEmployeePicker,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: hasValue ? colors.primaryBlue : colors.divider,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: AppTextStyles.body(
                  hasValue ? colors.textPrimary : colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.people_outline,
              color: hasValue ? colors.primaryBlue : colors.textSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeField(ThemeColors colors) {
    final hasValue = _startDate != null && _endDate != null;
    final displayText = hasValue
        ? '${FormatDate.shortDateWithYear(_startDate!)}  →  ${FormatDate.shortDateWithYear(_endDate!)}'
        : 'Pilih rentang tanggal';

    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: hasValue ? colors.primaryBlue : colors.divider,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: AppTextStyles.body(
                  hasValue ? colors.textPrimary : colors.textSecondary,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: hasValue ? colors.primaryBlue : colors.textSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
