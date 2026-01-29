import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

class LemburFilterBottomSheet extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime? startDate, DateTime? endDate) onApply;

  const LemburFilterBottomSheet({
    super.key,
    this.startDate,
    this.endDate,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
    required void Function(DateTime? startDate, DateTime? endDate) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LemburFilterBottomSheet(
        startDate: startDate,
        endDate: endDate,
        onApply: onApply,
      ),
    );
  }

  @override
  State<LemburFilterBottomSheet> createState() =>
      _LemburFilterBottomSheetState();
}

class _LemburFilterBottomSheetState extends State<LemburFilterBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
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
          SizedBox(height: 16.h),
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
          SizedBox(height: 16.h),
          Text(
            'Rentang Tanggal',
            style: AppTextStyles.body(colors.textSecondary),
          ),
          SizedBox(height: 12.h),
          _buildDateField(
            colors: colors,
            value: _formatDate(_startDate),
            onTap: () => _selectDate(true),
          ),
          SizedBox(height: 12.h),
          _buildDateField(
            colors: colors,
            value: _formatDate(_endDate),
            onTap: () => _selectDate(false),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_startDate, _endDate);
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

  Widget _buildDateField({
    required ThemeColors colors,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value.isEmpty ? '' : value,
              style: AppTextStyles.body(colors.textPrimary),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: colors.textSecondary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
