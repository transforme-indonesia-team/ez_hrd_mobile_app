import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/data/services/option_service.dart';

/// Wrapper for bottom sheet result
class FormDetailResult {
  final bool deleted;
  final CorrectionDetailEntry? entry;
  FormDetailResult({this.deleted = false, this.entry});
}

/// Data model for a single correction detail (local, not from API)
class CorrectionDetailEntry {
  final DateTime date;
  String? shiftCode;
  String? shiftId;
  String? checkInBefore;
  String? checkOutBefore;
  String? checkInAfter;
  String? checkOutAfter;
  String? remark;
  bool isEdited;

  CorrectionDetailEntry({
    required this.date,
    this.shiftCode,
    this.shiftId,
    this.checkInBefore,
    this.checkOutBefore,
    this.checkInAfter,
    this.checkOutAfter,
    this.remark,
    this.isEdited = false,
  });

  String get displayDate => FormatDate.shortDateWithYear(date);

  String get displayShift {
    if (shiftCode == null || shiftCode!.isEmpty) return 'FLEXIBLE';
    return shiftCode!
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ')
        .toUpperCase();
  }

  String get displayCheckInBefore => _formatTime(checkInBefore);
  String get displayCheckOutBefore => _formatTime(checkOutBefore);
  String get displayCheckInAfter => _formatTime(checkInAfter);
  String get displayCheckOutAfter => _formatTime(checkOutAfter);

  String _formatTime(String? dt) {
    if (dt == null || dt.isEmpty) return '--:--';
    try {
      final parsed = DateTime.parse(dt);
      return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dt;
    }
  }

  String get statusText {
    if (!isEdited) return 'Tidak ada perubahan';
    return 'Diperbarui';
  }
}

class FormDetailBottomSheet extends StatefulWidget {
  final CorrectionDetailEntry entry;

  const FormDetailBottomSheet({super.key, required this.entry});

  /// Show the bottom sheet and return result
  static Future<FormDetailResult?> show(
    BuildContext context, {
    required CorrectionDetailEntry entry,
  }) {
    return showModalBottomSheet<FormDetailResult?>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FormDetailBottomSheet(entry: entry),
    );
  }

  @override
  State<FormDetailBottomSheet> createState() => _FormDetailBottomSheetState();
}

class _FormDetailBottomSheetState extends State<FormDetailBottomSheet> {
  late TextEditingController _remarkController;
  late String? _shiftCode;
  late String? _shiftId;
  late String? _checkInBefore;
  late String? _checkOutBefore;
  DateTime? _checkInAfter;
  DateTime? _checkOutAfter;
  List<Map<String, dynamic>> _shiftOptions = [];
  bool _isLoadingShifts = true;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.entry.remark ?? '');
    _shiftCode = widget.entry.shiftCode;
    _shiftId = widget.entry.shiftId;
    _checkInBefore = widget.entry.checkInBefore;
    _checkOutBefore = widget.entry.checkOutBefore;

    // Parse existing after times
    _checkInAfter = _parseDatetime(widget.entry.checkInAfter);
    _checkOutAfter = _parseDatetime(widget.entry.checkOutAfter);

    _loadShiftOptions();
  }

  Future<void> _loadShiftOptions() async {
    try {
      final response = await OptionService().getShiftDaily();
      final records = response['original']?['records'] ?? response['records'];
      if (records is List && mounted) {
        setState(() {
          _shiftOptions = records
              .map((e) => e as Map<String, dynamic>)
              .toList();
          _isLoadingShifts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingShifts = false);
      }
    }
  }

  /// Build display label: "P_07_15 (07:00 - 15:00)" or just "SHIFT 1"
  String _buildShiftLabel(Map<String, dynamic> opt) {
    final label = opt['label'] as String? ?? '';
    final other = opt['other'] as Map<String, dynamic>?;
    if (other != null) {
      final start = other['start_time_shift'] as String?;
      final end = other['end_time_shift'] as String?;
      if (start != null && end != null) {
        return '$label ($start - $end)';
      }
    }
    return label;
  }

  /// Get display label for current selected shift
  String? get _selectedShiftDisplayLabel {
    if (_shiftCode == null) return null;
    // Try to find matching option to include time info
    for (final opt in _shiftOptions) {
      if (opt['value'] == _shiftId || opt['label'] == _shiftCode) {
        return _buildShiftLabel(opt);
      }
    }
    return _shiftCode;
  }

  void _showShiftPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final colors = context.colors;
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.55,
          maxChildSize: 0.85,
          builder: (ctx, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: colors.divider,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pilih Shift',
                        style: AppTextStyles.h3(colors.textPrimary),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: colors.divider),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: EdgeInsets.all(16.w),
                      itemCount: _shiftOptions.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (ctx, i) {
                        final opt = _shiftOptions[i];
                        final displayLabel = _buildShiftLabel(opt);
                        final value = opt['value'] as String? ?? '';
                        final isSelected = value == _shiftId;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _shiftCode = opt['label'] as String? ?? '';
                              _shiftId = value;
                            });
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primaryBlue.withValues(alpha: 0.05)
                                  : colors.background,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20.w,
                                  height: 20.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? colors.primaryBlue
                                          : colors.textSecondary,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            width: 10.w,
                                            height: 10.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: colors.primaryBlue,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    displayLabel,
                                    style: AppTextStyles.bodyMedium(
                                      isSelected
                                          ? colors.primaryBlue
                                          : colors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  DateTime? _parseDatetime(String? datetimeStr) {
    if (datetimeStr == null || datetimeStr.isEmpty) return null;
    try {
      return DateTime.parse(datetimeStr);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime({required bool isCheckIn}) async {
    final colors = context.colors;
    final now = DateTime.now();
    final currentDt = isCheckIn ? _checkInAfter : _checkOutAfter;

    // Step 1: Pick date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDt ?? widget.entry.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primaryBlue,
              onPrimary: Colors.white,
              surface: colors.background,
              onSurface: colors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    // Step 2: Pick time
    final initialTime = currentDt != null
        ? TimeOfDay(hour: currentDt.hour, minute: currentDt.minute)
        : TimeOfDay(hour: now.hour, minute: now.minute);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primaryBlue,
              onPrimary: Colors.white,
              surface: colors.background,
              onSurface: colors.textPrimary,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );

    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Validate: check-out can't be before check-in
    if (!isCheckIn &&
        _checkInAfter != null &&
        combined.isBefore(_checkInAfter!)) {
      if (mounted) {
        context.showErrorSnackbar('Jam keluar tidak boleh sebelum jam masuk');
      }
      return;
    }
    if (isCheckIn &&
        _checkOutAfter != null &&
        _checkOutAfter!.isBefore(combined)) {
      if (mounted) {
        context.showErrorSnackbar('Jam masuk tidak boleh setelah jam keluar');
      }
      return;
    }

    setState(() {
      if (isCheckIn) {
        _checkInAfter = combined;
      } else {
        _checkOutAfter = combined;
      }
    });
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-- : --';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(String? dtStr) {
    if (dtStr == null || dtStr.isEmpty) return '--:--';
    try {
      final parsed = DateTime.parse(dtStr);
      return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dtStr;
    }
  }

  String _formatDatetimeApi(DateTime dt) {
    return '${FormatDate.apiFormat(dt)} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';
  }

  void _onUpdate() {
    // Validate check-out not before check-in
    if (_checkInAfter != null &&
        _checkOutAfter != null &&
        _checkOutAfter!.isBefore(_checkInAfter!)) {
      context.showErrorSnackbar('Jam keluar tidak boleh sebelum jam masuk');
      return;
    }

    final entry = widget.entry;
    entry.remark = _remarkController.text.trim();
    entry.shiftCode = _shiftCode;
    entry.shiftId = _shiftId;

    if (_checkInAfter != null) {
      entry.checkInAfter = _formatDatetimeApi(_checkInAfter!);
    }
    if (_checkOutAfter != null) {
      entry.checkOutAfter = _formatDatetimeApi(_checkOutAfter!);
    }

    entry.isEdited = true;
    Navigator.pop(context, FormDetailResult(entry: entry));
  }

  void _onDelete() {
    Navigator.pop(context, FormDetailResult(deleted: true));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.95,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Form Koreksi Kehadiran',
                    style: AppTextStyles.h3(colors.textPrimary),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Alasan
                      Text(
                        'Alasan',
                        style: AppTextStyles.body(
                          colors.textSecondary,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TextField(
                        controller: _remarkController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Masukan alasan koreksi',
                          hintStyle: AppTextStyles.body(
                            colors.textSecondary,
                            fontSize: 13.sp,
                          ),
                          filled: true,
                          fillColor: colors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: colors.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: colors.divider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: colors.primaryBlue),
                          ),
                          contentPadding: EdgeInsets.all(10.w),
                        ),
                        style: AppTextStyles.body(
                          colors.textPrimary,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Shift
                      Text(
                        'Shift',
                        style: AppTextStyles.body(
                          colors.textSecondary,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      GestureDetector(
                        onTap: _isLoadingShifts ? null : _showShiftPicker,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: colors.divider),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _isLoadingShifts
                                    ? Text(
                                        'Memuat shift...',
                                        style: AppTextStyles.body(
                                          colors.textSecondary,
                                          fontSize: 13.sp,
                                        ),
                                      )
                                    : Text(
                                        _selectedShiftDisplayLabel ??
                                            'Pilih Shift',
                                        style: AppTextStyles.body(
                                          _shiftCode != null
                                              ? colors.textPrimary
                                              : colors.textSecondary,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: colors.textSecondary,
                                size: 18.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // SEBELUMNYA
                      Text(
                        'SEBELUMNYA',
                        style: AppTextStyles.bodySemiBold(colors.textPrimary),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jam Masuk',
                                  style: AppTextStyles.caption(
                                    colors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _formatTime(_checkInBefore),
                                  style: AppTextStyles.bodyMedium(
                                    colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jam Keluar',
                                  style: AppTextStyles.caption(
                                    colors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _formatTime(_checkOutBefore),
                                  style: AppTextStyles.bodyMedium(
                                    colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // SESUDAHNYA
                      Text(
                        'SESUDAHNYA',
                        style: AppTextStyles.bodySemiBold(colors.textPrimary),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jam Masuk',
                                  style: AppTextStyles.caption(
                                    colors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                _buildDateTimePickerField(
                                  colors,
                                  dateTime: _checkInAfter,
                                  onTap: () => _selectDateTime(isCheckIn: true),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jam Keluar',
                                  style: AppTextStyles.caption(
                                    colors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                _buildDateTimePickerField(
                                  colors,
                                  dateTime: _checkOutAfter,
                                  onTap: () =>
                                      _selectDateTime(isCheckIn: false),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
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
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Hapus',
                          style: AppTextStyles.button(Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _onUpdate,
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
                          'Memperbarui',
                          style: AppTextStyles.button(Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateTimePickerField(
    ThemeColors colors, {
    required DateTime? dateTime,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _formatDateTime(dateTime),
                style: AppTextStyles.body(
                  dateTime != null ? colors.textPrimary : colors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: colors.textSecondary,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
