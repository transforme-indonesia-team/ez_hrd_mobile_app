import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/data/models/overtime_type_model.dart';
import 'package:hrd_app/features/lembur/widgets/overtime_type_bottom_sheet.dart';
import 'package:provider/provider.dart';

class FormLemburScreen extends StatefulWidget {
  const FormLemburScreen({super.key});

  @override
  State<FormLemburScreen> createState() => _FormLemburScreenState();
}

class _FormLemburScreenState extends State<FormLemburScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  OvertimeTypeModel? _selectedOvertimeType;
  final List<String> _attachments = [];

  // Dummy overtime types
  final List<OvertimeTypeModel> _overtimeTypes = const [
    OvertimeTypeModel(id: '1', name: 'Jam Lembur'),
    OvertimeTypeModel(id: '2', name: 'Cuti Tambahan'),
  ];

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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
      builder: (context, child) {
        final colors = context.colors;
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

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectOvertimeType() async {
    final selected = await OvertimeTypeBottomSheet.show(
      context,
      types: _overtimeTypes,
      selectedType: _selectedOvertimeType,
    );

    if (selected != null) {
      setState(() => _selectedOvertimeType = selected);
    }
  }

  void _pickFile() {
    // TODO: Implement file picker when file_picker package is added
    context.showInfoSnackbar('Fitur lampiran belum tersedia');
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _submit() {
    if (_startDate == null || _endDate == null) {
      context.showErrorSnackbar('Silakan pilih tanggal');
      return;
    }

    if (_selectedOvertimeType == null) {
      context.showErrorSnackbar('Silakan pilih tipe lembur');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      context.showErrorSnackbar('Silakan isi keterangan');
      return;
    }

    // TODO: Submit to API
    context.showSuccessSnackbar('Permintaan lembur berhasil diajukan');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Form Lembur', style: AppTextStyles.h3(colors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(colors, 'Permintaan Untuk'),
            SizedBox(height: 8.h),
            _buildReadOnlyField(
              colors,
              value: user?.name ?? 'User',
              icon: Icons.person_outline,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(colors, 'Tanggal Mulai'),
                      SizedBox(height: 8.h),
                      _buildDateField(
                        colors,
                        date: _startDate,
                        onTap: () => _selectDate(true),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(colors, 'Tanggal Berakhir'),
                      SizedBox(height: 8.h),
                      _buildDateField(
                        colors,
                        date: _endDate,
                        onTap: () => _selectDate(false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildLabel(colors, 'Tipe Lembur'),
            SizedBox(height: 8.h),
            _buildDropdownField(
              colors,
              value: _selectedOvertimeType?.displayName,
              hint: 'Pilih tipe lembur',
              onTap: _selectOvertimeType,
              onClear: _selectedOvertimeType != null
                  ? () => setState(() => _selectedOvertimeType = null)
                  : null,
            ),
            SizedBox(height: 16.h),
            _buildLabel(colors, 'Keterangan'),
            SizedBox(height: 8.h),
            _buildTextField(colors),
            SizedBox(height: 16.h),
            _buildLabel(colors, 'Lampiran'),
            SizedBox(height: 8.h),
            _buildAttachmentSection(colors),
            SizedBox(height: 8.h),
            Text(
              'Berkas yang Didukung: txt,doc,docx,jpg,png,gif,xls,pdf',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
            SizedBox(height: 80.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(colors),
    );
  }

  Widget _buildLabel(ThemeColors colors, String text) {
    return Text(text, style: AppTextStyles.body(colors.textSecondary));
  }

  Widget _buildReadOnlyField(
    ThemeColors colors, {
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(value, style: AppTextStyles.body(colors.textPrimary)),
          ),
          Icon(icon, color: colors.textSecondary, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildDateField(
    ThemeColors colors, {
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null ? FormatDate.shortDateWithYear(date) : '',
                style: AppTextStyles.body(colors.textPrimary),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: colors.textSecondary,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    ThemeColors colors, {
    required String? value,
    required String hint,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: AppTextStyles.body(
                  value != null ? colors.textPrimary : colors.textSecondary,
                ),
              ),
            ),
            if (onClear != null) ...[
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  color: colors.textSecondary,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 8.w),
            ],
            Icon(
              Icons.keyboard_arrow_down,
              color: colors.textSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(ThemeColors colors) {
    return TextField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Tulis alasan',
        hintStyle: AppTextStyles.body(colors.textSecondary),
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
        contentPadding: EdgeInsets.all(12.w),
      ),
      style: AppTextStyles.body(colors.textPrimary),
    );
  }

  Widget _buildAttachmentSection(ThemeColors colors) {
    return Column(
      children: [
        if (_attachments.isNotEmpty) ...[
          ...List.generate(_attachments.length, (index) {
            final fileName = _attachments[index];
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: colors.divider),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.attachment,
                    color: colors.textSecondary,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      fileName,
                      style: AppTextStyles.body(colors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _removeAttachment(index),
                    child: Icon(Icons.close, color: colors.error, size: 18.sp),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 8.h),
        ],
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: colors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: colors.primaryBlue, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Pilih File',
                  style: AppTextStyles.bodyMedium(colors.primaryBlue),
                ),
              ],
            ),
          ),
        ),
      ],
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
        child: ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primaryBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text('Lanjut', style: AppTextStyles.button(Colors.white)),
        ),
      ),
    );
  }
}
