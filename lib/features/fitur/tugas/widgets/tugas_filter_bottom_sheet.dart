import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class TugasFilterBottomSheet extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final String? initialStatus;
  final String? initialPrioritas;
  final Function(DateTimeRange? dateRange, String? status, String? prioritas)?
  onApply;

  const TugasFilterBottomSheet({
    super.key,
    this.initialDateRange,
    this.initialStatus,
    this.initialPrioritas,
    this.onApply,
  });

  @override
  State<TugasFilterBottomSheet> createState() => _TugasFilterBottomSheetState();
}

class _TugasFilterBottomSheetState extends State<TugasFilterBottomSheet> {
  DateTimeRange? _selectedDateRange;
  String? _selectedStatus;
  String? _selectedPrioritas;

  final List<String> _statusOptions = [
    'Cari Status',
    'Tugas Baru',
    'Sedang Dikerjakan',
    'Menunggu Persetujuan',
    'Selesai',
    'Dibatalkan',
  ];
  final List<String> _prioritasOptions = [
    'Cari Prioritas',
    'Tinggi',
    'Sedang',
    'Rendah',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDateRange = widget.initialDateRange;
    _selectedStatus = widget.initialStatus ?? 'Cari Status';
    _selectedPrioritas = widget.initialPrioritas ?? 'Cari Prioritas';
  }

  void _resetFilter() {
    setState(() {
      _selectedDateRange = null;
      _selectedStatus = 'Cari Status';
      _selectedPrioritas = 'Cari Prioritas';
    });
  }

  Future<void> _pickDateRange(BuildContext context, ThemeColors colors) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: colors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _showDropdown(
    ThemeColors colors,
    List<String> options,
    String currentValue,
    ValueChanged<String> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options[index];
                  final isSelected = item == currentValue;
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(item);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 16.h,
                        horizontal: 20.w,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: colors.divider),
                        ),
                        color: isSelected
                            ? colors.primaryBlue.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Text(
                        item,
                        style: isSelected
                            ? AppTextStyles.bodyMedium(colors.primaryBlue).copyWith(fontSize: 13.sp)
                            : AppTextStyles.body(colors.textPrimary).copyWith(fontSize: 13.sp),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(ThemeColors colors, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(text, style: AppTextStyles.smallMedium(colors.textSecondary).copyWith(fontSize: 12.sp)),
    );
  }

  Widget _buildFieldContainer(
    ThemeColors colors,
    String text,
    IconData iconData, {
    bool isDatePlaceholder = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: isDatePlaceholder
                ? AppTextStyles.body(colors.textSecondary).copyWith(fontSize: 13.sp)
                : AppTextStyles.body(colors.textPrimary).copyWith(fontSize: 13.sp),
          ),
          Icon(iconData, color: colors.textSecondary, size: 18.sp),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    String dateRangeText = 'Pilih rentang tanggal';
    bool isDatePlaceholder = true;
    if (_selectedDateRange != null) {
      final start = DateFormat('dd MMM yyyy').format(_selectedDateRange!.start);
      final end = DateFormat('dd MMM yyyy').format(_selectedDateRange!.end);
      dateRangeText = '$start - $end';
      isDatePlaceholder = false;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 12.h,
              bottom: MediaQuery.of(context).padding.bottom + 20.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                SizedBox(height: 12.h),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sortir',
                      style: AppTextStyles.bodyLarge(
                        colors.textSecondary,
                      ).copyWith(fontWeight: FontWeight.w600, fontSize: 18.sp),
                    ),
                    GestureDetector(
                      onTap: _resetFilter,
                      child: Text(
                        'Hapus',
                        style: AppTextStyles.smallMedium(
                          colors.primaryBlue,
                        ).copyWith(fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Tanggal
                _buildLabel(colors, 'Rentang Tanggal'),
                GestureDetector(
                  onTap: () => _pickDateRange(context, colors),
                  child: _buildFieldContainer(
                    colors,
                    dateRangeText,
                    Icons.calendar_today_outlined,
                    isDatePlaceholder: isDatePlaceholder,
                  ),
                ),
                SizedBox(height: 12.h),

                // Status
                _buildLabel(colors, 'Status'),
                GestureDetector(
                  onTap: () {
                    _showDropdown(
                      colors,
                      _statusOptions,
                      _selectedStatus ?? 'Cari Status',
                      (val) {
                        setState(() {
                          _selectedStatus = val;
                        });
                      },
                    );
                  },
                  child: _buildFieldContainer(
                    colors,
                    _selectedStatus ?? 'Cari Status',
                    Icons.keyboard_arrow_down,
                    isDatePlaceholder: _selectedStatus == 'Cari Status',
                  ),
                ),
                SizedBox(height: 12.h),

                // Prioritas
                _buildLabel(colors, 'Prioritas'),
                GestureDetector(
                  onTap: () {
                    _showDropdown(
                      colors,
                      _prioritasOptions,
                      _selectedPrioritas ?? 'Cari Prioritas',
                      (val) {
                        setState(() {
                          _selectedPrioritas = val;
                        });
                      },
                    );
                  },
                  child: _buildFieldContainer(
                    colors,
                    _selectedPrioritas ?? 'Cari Prioritas',
                    Icons.keyboard_arrow_down,
                    isDatePlaceholder: _selectedPrioritas == 'Cari Prioritas',
                  ),
                ),
                SizedBox(height: 20.h),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (widget.onApply != null) {
                        widget.onApply!(
                          _selectedDateRange,
                          _selectedStatus,
                          _selectedPrioritas,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Terapkan',
                      style: AppTextStyles.button(Colors.white).copyWith(fontSize: 13.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
