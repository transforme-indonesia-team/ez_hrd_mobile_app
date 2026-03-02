import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';

class KoreksiFilterResult {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  KoreksiFilterResult({this.startDate, this.endDate, this.status});
}

class KoreksiFilterBottomSheet extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final void Function(KoreksiFilterResult result) onApply;

  const KoreksiFilterBottomSheet({
    super.key,
    this.startDate,
    this.endDate,
    this.status,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    required void Function(KoreksiFilterResult result) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KoreksiFilterBottomSheet(
        startDate: startDate,
        endDate: endDate,
        status: status,
        onApply: onApply,
      ),
    );
  }

  @override
  State<KoreksiFilterBottomSheet> createState() =>
      _KoreksiFilterBottomSheetState();
}

class _KoreksiFilterBottomSheetState extends State<KoreksiFilterBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _status;

  static const _statusOptions = [
    {'value': null, 'label': 'Semua'},
    {'value': 'UNVERIFIED', 'label': 'Unverified'},
    {'value': 'WAITING_APPROVAL', 'label': 'Menunggu Persetujuan'},
    {'value': 'APPROVED', 'label': 'Disetujui'},
    {'value': 'REJECTED', 'label': 'Ditolak'},
  ];

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _status = widget.status;
  }

  Future<void> _selectDateRange() async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now(),
      end: _endDate ?? DateTime.now().add(const Duration(days: 7)),
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

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _status = null;
    });
  }

  String _formatDateRange() {
    if (_startDate == null && _endDate == null) {
      return 'Pilih rentang tanggal';
    }
    final start = _startDate != null ? FormatDate.shortDate(_startDate!) : '-';
    final end = _endDate != null ? FormatDate.shortDate(_endDate!) : '-';
    return '$start  →  $end';
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter', style: AppTextStyles.h4(colors.textPrimary)),
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'Hapus',
                  style: AppTextStyles.bodyMedium(colors.primaryBlue),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Date Range
          Text(
            'Rentang Tanggal',
            style: AppTextStyles.body(colors.textSecondary),
          ),
          SizedBox(height: 8.h),
          _buildDateRangeField(colors: colors),
          SizedBox(height: 16.h),

          // Status
          Text('Status', style: AppTextStyles.body(colors.textSecondary)),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _statusOptions.map((opt) {
              final value = opt['value'];
              final label = opt['label'] as String;
              final isSelected = _status == value;
              return GestureDetector(
                onTap: () => setState(() => _status = value),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primaryBlue.withValues(alpha: 0.1)
                        : colors.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? colors.primaryBlue : colors.divider,
                    ),
                  ),
                  child: Text(
                    label,
                    style: AppTextStyles.body(
                      isSelected ? colors.primaryBlue : colors.textPrimary,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  KoreksiFilterResult(
                    startDate: _startDate,
                    endDate: _endDate,
                    status: _status,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Terapkan',
                style: AppTextStyles.button(Colors.white, fontSize: 14.sp),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
        ],
      ),
    );
  }

  Widget _buildDateRangeField({required ThemeColors colors}) {
    final hasValue = _startDate != null && _endDate != null;

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
            Icon(
              Icons.date_range_outlined,
              color: hasValue ? colors.primaryBlue : colors.textSecondary,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                _formatDateRange(),
                style: AppTextStyles.body(
                  hasValue ? colors.textPrimary : colors.textSecondary,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textSecondary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
