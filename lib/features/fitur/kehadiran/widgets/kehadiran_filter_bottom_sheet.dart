import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';

class KehadiranFilterBottomSheet extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? employeeSearch;
  final bool showWithoutFaceRecognition;
  final bool showWithoutLocation;
  final bool showWithoutPhoto;
  final void Function({
    DateTime? startDate,
    DateTime? endDate,
    String? employeeSearch,
    bool showWithoutFaceRecognition,
    bool showWithoutLocation,
    bool showWithoutPhoto,
  })
  onApply;

  const KehadiranFilterBottomSheet({
    super.key,
    this.startDate,
    this.endDate,
    this.employeeSearch,
    this.showWithoutFaceRecognition = false,
    this.showWithoutLocation = false,
    this.showWithoutPhoto = false,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
    String? employeeSearch,
    bool showWithoutFaceRecognition = false,
    bool showWithoutLocation = false,
    bool showWithoutPhoto = false,
    required void Function({
      DateTime? startDate,
      DateTime? endDate,
      String? employeeSearch,
      bool showWithoutFaceRecognition,
      bool showWithoutLocation,
      bool showWithoutPhoto,
    })
    onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KehadiranFilterBottomSheet(
        startDate: startDate,
        endDate: endDate,
        employeeSearch: employeeSearch,
        showWithoutFaceRecognition: showWithoutFaceRecognition,
        showWithoutLocation: showWithoutLocation,
        showWithoutPhoto: showWithoutPhoto,
        onApply: onApply,
      ),
    );
  }

  @override
  State<KehadiranFilterBottomSheet> createState() =>
      _KehadiranFilterBottomSheetState();
}

class _KehadiranFilterBottomSheetState
    extends State<KehadiranFilterBottomSheet> {
  late TextEditingController _employeeController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showWithoutFaceRecognition = false;
  bool _showWithoutLocation = false;
  bool _showWithoutPhoto = false;

  @override
  void initState() {
    super.initState();
    _employeeController = TextEditingController(text: widget.employeeSearch);
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _showWithoutFaceRecognition = widget.showWithoutFaceRecognition;
    _showWithoutLocation = widget.showWithoutLocation;
    _showWithoutPhoto = widget.showWithoutPhoto;
  }

  @override
  void dispose() {
    _employeeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      end: _endDate ?? DateTime.now(),
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
      _employeeController.clear();
      _startDate = null;
      _endDate = null;
      _showWithoutFaceRecognition = false;
      _showWithoutLocation = false;
      _showWithoutPhoto = false;
    });
  }

  void _applyFilters() {
    widget.onApply(
      startDate: _startDate,
      endDate: _endDate,
      employeeSearch: _employeeController.text.isEmpty
          ? null
          : _employeeController.text,
      showWithoutFaceRecognition: _showWithoutFaceRecognition,
      showWithoutLocation: _showWithoutLocation,
      showWithoutPhoto: _showWithoutPhoto,
    );
    Navigator.pop(context);
  }

  String _formatDateRange() {
    if (_startDate == null && _endDate == null) {
      return 'Pilih rentang tanggal';
    }
    final start = _startDate != null
        ? FormatDate.shortDateWithYear(_startDate!)
        : '-';
    final end = _endDate != null
        ? FormatDate.shortDateWithYear(_endDate!)
        : '-';
    return '$start - $end';
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
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

            // Title
            Text('Sortir', style: AppTextStyles.h4(colors.textPrimary)),
            SizedBox(height: 16.h),

            // Pilih Karyawan
            _buildTextField(
              colors,
              controller: _employeeController,
              hint: 'Pilih Karyawan',
              suffixIcon: Icons.people_outline,
            ),
            SizedBox(height: 16.h),

            // Rentang Tanggal
            Text(
              'Rentang Tanggal',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
            SizedBox(height: 8.h),
            _buildDateRangeField(colors: colors),
            SizedBox(height: 16.h),

            // Lokasi Kerja
            _buildTextField(colors, hint: 'Pilih Lokasi Kerja'),
            SizedBox(height: 16.h),

            // Status
            _buildTextField(colors, hint: 'Pilih Status'),
            SizedBox(height: 16.h),

            // Pengenalan Wajah section
            Text(
              'Pengenalan Wajah',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
            Text(
              'Ambang Batas Global Pengenalan Wajah = 98%',
              style: AppTextStyles.xSmall(colors.textSecondary),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(colors, hint: '0', enabled: false),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildTextField(colors, hint: '100', enabled: false),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Checkbox: Tampilkan tanpa Pengenalan Wajah
            _buildCheckbox(
              colors,
              label: 'Tampilkan tanpa Pengenalan Wajah',
              value: _showWithoutFaceRecognition,
              onChanged: (val) =>
                  setState(() => _showWithoutFaceRecognition = val ?? false),
            ),
            SizedBox(height: 12.h),

            // Opsi Lainnya
            Text(
              'Opsi Lainnya',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
            SizedBox(height: 8.h),
            _buildCheckbox(
              colors,
              label: 'Tampilkan semua tanpa lokasi gps',
              value: _showWithoutLocation,
              onChanged: (val) =>
                  setState(() => _showWithoutLocation = val ?? false),
            ),
            _buildCheckbox(
              colors,
              label: 'Tampilkan semua tanpa foto',
              value: _showWithoutPhoto,
              onChanged: (val) =>
                  setState(() => _showWithoutPhoto = val ?? false),
            ),
            SizedBox(height: 24.h),

            // Bottom buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _clearFilters,
                    child: Text(
                      'Hapus',
                      style: AppTextStyles.button(colors.primaryBlue),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
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
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    ThemeColors colors, {
    TextEditingController? controller,
    required String hint,
    IconData? suffixIcon,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: AppTextStyles.body(colors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(colors.textSecondary),
        filled: true,
        fillColor: colors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
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
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: colors.textSecondary, size: 20.sp)
            : null,
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
            Expanded(
              child: Text(
                _formatDateRange(),
                style: AppTextStyles.body(
                  hasValue ? colors.textPrimary : colors.textSecondary,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: colors.textSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(
    ThemeColors colors, {
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 24.w,
          height: 24.w,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: colors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(label, style: AppTextStyles.small(colors.textPrimary)),
        ),
      ],
    );
  }
}
