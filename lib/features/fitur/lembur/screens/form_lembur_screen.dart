import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/data/models/overtime_type_model.dart';
import 'package:hrd_app/data/services/overtime_service.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/overtime_type_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/file_picker_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class FormLemburScreen extends StatefulWidget {
  const FormLemburScreen({super.key});

  @override
  State<FormLemburScreen> createState() => _FormLemburScreenState();
}

class _FormLemburScreenState extends State<FormLemburScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  DateTime? _overtimeDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  OvertimeTypeModel? _selectedOvertimeType;

  // Store actual file, not just name
  File? _attachmentFile;
  String? _attachmentFileName;

  bool _isSubmitting = false;

  // Dummy overtime types
  final List<OvertimeTypeModel> _overtimeTypes = const [
    OvertimeTypeModel(id: '1', name: 'Jam Lembur'),
    OvertimeTypeModel(id: '2', name: 'Cuti Tambahan'),
  ];

  @override
  void initState() {
    super.initState();
    _overtimeDate = DateTime.now();
    _startTime = const TimeOfDay(hour: 17, minute: 0);
    _endTime = const TimeOfDay(hour: 20, minute: 0);
    // Default tipe lembur = Jam Lembur
    _selectedOvertimeType = _overtimeTypes.first;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _overtimeDate ?? DateTime.now(),
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
      setState(() => _overtimeDate = picked);
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final initialTime = isStart
        ? (_startTime ?? const TimeOfDay(hour: 17, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 20, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
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
          _startTime = picked;
        } else {
          _endTime = picked;
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

  Future<void> _pickFile() async {
    final type = await FilePickerBottomSheet.show(context);

    if (type == null || !mounted) return;

    try {
      switch (type) {
        case FilePickerType.camera:
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.camera,
            imageQuality: 80,
          );
          if (image != null) {
            _setAttachment(File(image.path), image.name);
          }
          break;
        case FilePickerType.gallery:
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
          );
          if (image != null) {
            _setAttachment(File(image.path), image.name);
          }
          break;
        case FilePickerType.file:
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: [
              'txt',
              'doc',
              'docx',
              'jpg',
              'png',
              'gif',
              'xls',
              'xlsx',
              'pdf',
            ],
          );
          if (result != null && result.files.isNotEmpty) {
            final file = result.files.first;
            if (file.path != null) {
              _setAttachment(File(file.path!), file.name);
            }
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar('Gagal memilih file: ${e.toString()}');
      }
    }
  }

  void _setAttachment(File file, String fileName) {
    setState(() {
      _attachmentFile = file;
      _attachmentFileName = fileName;
    });
    if (mounted) {
      context.showSuccessSnackbar('File "$fileName" berhasil dipilih');
    }
  }

  void _removeAttachment() {
    setState(() {
      _attachmentFile = null;
      _attachmentFileName = null;
    });
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _submit() async {
    if (_overtimeDate == null) {
      context.showErrorSnackbar('Silakan pilih tanggal lembur');
      return;
    }

    if (_startTime == null || _endTime == null) {
      context.showErrorSnackbar('Silakan pilih jam mulai dan jam berakhir');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      context.showErrorSnackbar('Silakan isi keterangan');
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      context.showErrorSnackbar('User tidak ditemukan');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get company_id from user's companies (index 0)
      final companyId = user.companies?.isNotEmpty == true
          ? user.companies!.first.companyId
          : '';

      if (companyId.isEmpty) {
        throw Exception('Company tidak ditemukan');
      }

      // Step 1: Get reservation number from API
      final reservationResponse = await OvertimeService().getReservationNumber(
        reservationType: 'OVERTIME',
        companyId: companyId,
      );
      final records =
          reservationResponse['original']?['records'] as Map<String, dynamic>?;
      final requestNumber = records?['request_number'] as String?;

      if (requestNumber == null || requestNumber.isEmpty) {
        throw Exception('Gagal mendapatkan nomor permintaan');
      }

      // Step 2: Submit overtime request with request number and employee_id
      await OvertimeService().createOvertime(
        overtimeRequestNo: requestNumber,
        dateOvertime: DateFormat('yyyy-MM-dd').format(_overtimeDate!),
        startOvertime: _formatTimeOfDay(_startTime),
        endOvertime: _formatTimeOfDay(_endTime),
        remarkOvertime: _descriptionController.text.trim(),
        employeeId: user.id,
        fileAttachment: _attachmentFile,
      );

      if (mounted) {
        context.showSuccessSnackbar('Permintaan lembur berhasil diajukan');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar('Gagal mengajukan lembur: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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

            // Tanggal Lembur (single date)
            _buildLabel(colors, 'Tanggal Lembur'),
            SizedBox(height: 8.h),
            _buildDateField(colors, date: _overtimeDate, onTap: _selectDate),
            SizedBox(height: 16.h),

            // Jam Mulai & Jam Berakhir
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(colors, 'Jam Mulai'),
                      SizedBox(height: 8.h),
                      _buildTimeField(
                        colors,
                        time: _startTime,
                        onTap: () => _selectTime(true),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(colors, 'Jam Berakhir'),
                      SizedBox(height: 8.h),
                      _buildTimeField(
                        colors,
                        time: _endTime,
                        onTap: () => _selectTime(false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Tipe Lembur
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
                date != null
                    ? FormatDate.shortDateWithYear(date)
                    : 'Pilih tanggal',
                style: AppTextStyles.body(
                  date != null ? colors.textPrimary : colors.textSecondary,
                ),
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

  Widget _buildTimeField(
    ThemeColors colors, {
    required TimeOfDay? time,
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
                time != null ? _formatTimeOfDay(time) : 'Pilih jam',
                style: AppTextStyles.body(
                  time != null ? colors.textPrimary : colors.textSecondary,
                ),
              ),
            ),
            Icon(
              Icons.access_time_outlined,
              color: colors.textSecondary,
              size: 18.sp,
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
        hintText: 'Tulis alasan lembur',
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
        if (_attachmentFileName != null) ...[
          Container(
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
                    _attachmentFileName!,
                    style: AppTextStyles.body(colors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: _removeAttachment,
                  child: Icon(Icons.close, color: colors.error, size: 18.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
        if (_attachmentFileName == null)
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
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primaryBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: colors.primaryBlue.withValues(alpha: 0.5),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: _isSubmitting
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Ajukan Lembur',
                  style: AppTextStyles.button(Colors.white),
                ),
        ),
      ),
    );
  }
}
