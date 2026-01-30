import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/data/models/overtime_employee_model.dart';
import 'package:hrd_app/data/models/overtime_type_model.dart';
import 'package:hrd_app/data/services/overtime_service.dart';
import 'package:hrd_app/data/services/reservation_service.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/overtime_type_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/file_picker_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class FormLemburScreen extends StatefulWidget {
  final OvertimeEmployeeModel? existingOvertime;

  const FormLemburScreen({super.key, this.existingOvertime});

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

    // Check if editing existing overtime
    if (widget.existingOvertime != null) {
      _populateExistingData();
    } else {
      _overtimeDate = DateTime.now();
      _selectedOvertimeType = _overtimeTypes.first;
    }
  }

  void _populateExistingData() {
    final overtime = widget.existingOvertime!;

    // Parse date
    if (overtime.dateOvertime != null) {
      try {
        _overtimeDate = DateFormat('yyyy-MM-dd').parse(overtime.dateOvertime!);
      } catch (e) {
        _overtimeDate = DateTime.now();
      }
    }

    // Parse times
    if (overtime.startOvertime != null) {
      final parts = overtime.startOvertime!.split(':');
      if (parts.length >= 2) {
        _startTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    if (overtime.endOvertime != null) {
      final parts = overtime.endOvertime!.split(':');
      if (parts.length >= 2) {
        _endTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 17,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    // Set description
    if (overtime.remarkOvertime != null) {
      _descriptionController.text = overtime.remarkOvertime!;
    }

    // Set file name if exists
    if (overtime.hasAttachment) {
      _attachmentFileName = overtime.fileNameOvertime ?? 'File terlampir';
    }

    // Default overtime type
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
        ? (_startTime ?? const TimeOfDay(hour: 8, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 17, minute: 0));

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
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
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
            await _setAttachment(File(image.path), image.name);
          }
          break;
        case FilePickerType.gallery:
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
          );
          if (image != null) {
            await _setAttachment(File(image.path), image.name);
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
              await _setAttachment(File(file.path!), file.name);
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

  /// Maksimal ukuran file 1MB
  static const int _maxFileSizeBytes = 1 * 1024 * 1024; // 1MB

  Future<void> _setAttachment(File file, String fileName) async {
    // Validasi ukuran file
    final fileSize = await file.length();
    if (fileSize > _maxFileSizeBytes) {
      if (mounted) {
        final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
        context.showErrorSnackbar(
          'Ukuran file "$fileName" ($fileSizeMB MB) melebihi batas maksimal 1 MB',
        );
      }
      return;
    }

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

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      context.showErrorSnackbar('User tidak ditemukan');
      return;
    }

    final companyId = user.companies?.isNotEmpty == true
        ? user.companies!.first.companyId
        : '';

    if (user.employeeId == null || user.employeeId!.isEmpty) {
      throw Exception('Employee ID tidak ditemukan');
    }

    if (companyId.isEmpty) {
      throw Exception('Company tidak ditemukan');
    }

    setState(() => _isSubmitting = true);

    try {
      final isEditMode = widget.existingOvertime != null;

      if (isEditMode) {
        await OvertimeService().updateOvertime(
          overtimeId: widget.existingOvertime!.id,
          overtimeRequestNo: widget.existingOvertime!.displayOvertimeRequestNo,
          dateOvertime: DateFormat('yyyy-MM-dd').format(_overtimeDate!),
          startOvertime: _formatTimeOfDay(_startTime),
          endOvertime: _formatTimeOfDay(_endTime),
          remarkOvertime: _descriptionController.text.trim(),
          fileAttachment: _attachmentFile,
          employeeId: user.employeeId!,
        );

        if (mounted) {
          context.showSuccessSnackbar('Perubahan berhasil disimpan');
          Navigator.pop(context, true);
        }
      } else {
        // Step 1: Get reservation number from API
        final reservationResponse = await ReservationService()
            .getReservationNumber(
              reservationType: 'OVERTIME',
              companyId: companyId,
            );
        final records =
            reservationResponse['original']?['records']
                as Map<String, dynamic>?;
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
          employeeId: user.employeeId!,
          fileAttachment: _attachmentFile,
        );

        if (mounted) {
          context.showSuccessSnackbar('Permintaan lembur berhasil diajukan');
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar(
          'Gagal ${widget.existingOvertime != null ? 'menyimpan perubahan' : 'mengajukan lembur'}: ${e.toString()}',
        );
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
        title: Text(
          widget.existingOvertime != null ? 'Edit Lembur' : 'Form Lembur',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(colors, 'Permintaan Untuk'),
            SizedBox(height: 6.h),
            _buildReadOnlyField(
              colors,
              value: user?.name ?? 'User',
              icon: Icons.person_outline,
            ),
            SizedBox(height: 10.h),

            // Tanggal Lembur (single date)
            _buildLabel(colors, 'Tanggal Lembur'),
            SizedBox(height: 6.h),
            _buildDateField(colors, date: _overtimeDate, onTap: _selectDate),
            SizedBox(height: 10.h),

            // Jam Mulai & Jam Berakhir
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(colors, 'Jam Mulai'),
                      SizedBox(height: 6.h),
                      _buildTimeField(
                        colors,
                        time: _startTime,
                        onTap: () => _selectTime(true),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(colors, 'Jam Berakhir'),
                      SizedBox(height: 6.h),
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
            SizedBox(height: 10.h),

            // Tipe Lembur
            _buildLabel(colors, 'Tipe Lembur'),
            SizedBox(height: 6.h),
            _buildDropdownField(
              colors,
              value: _selectedOvertimeType?.displayName,
              hint: 'Pilih tipe lembur',
              onTap: _selectOvertimeType,
              onClear: _selectedOvertimeType != null
                  ? () => setState(() => _selectedOvertimeType = null)
                  : null,
            ),
            SizedBox(height: 10.h),

            _buildLabel(colors, 'Keterangan'),
            SizedBox(height: 6.h),
            _buildTextField(colors),
            SizedBox(height: 10.h),

            _buildLabel(colors, 'Lampiran'),
            SizedBox(height: 6.h),
            _buildAttachmentSection(colors),
            SizedBox(height: 6.h),
            Text(
              'Berkas yang Didukung: doc,jpg,ods,png,txt,doc,pdf',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
            SizedBox(height: 60.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(colors),
    );
  }

  Widget _buildLabel(ThemeColors colors, String text) {
    return Text(
      text,
      style: AppTextStyles.body(colors.textSecondary, fontSize: 13.sp),
    );
  }

  Widget _buildReadOnlyField(
    ThemeColors colors, {
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body(colors.textPrimary, fontSize: 13.sp),
            ),
          ),
          Icon(icon, color: colors.textSecondary, size: 18.sp),
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
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
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
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
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
                  fontSize: 13.sp,
                ),
              ),
            ),
            if (onClear != null) ...[
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  color: colors.textSecondary,
                  size: 14.sp,
                ),
              ),
              SizedBox(width: 6.w),
            ],
            Icon(
              Icons.keyboard_arrow_down,
              color: colors.textSecondary,
              size: 18.sp,
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
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
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
                  fontSize: 13.sp,
                ),
              ),
            ),
            Icon(
              Icons.access_time_outlined,
              color: colors.textSecondary,
              size: 14.sp,
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
      maxLength: 30,
      decoration: InputDecoration(
        hintText: 'Masukan Komentar',
        hintStyle: AppTextStyles.body(colors.textSecondary, fontSize: 13.sp),
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
      style: AppTextStyles.body(colors.textPrimary, fontSize: 13.sp),
    );
  }

  Widget _buildAttachmentSection(ThemeColors colors) {
    return Column(
      children: [
        if (_attachmentFileName != null) ...[
          Container(
            margin: EdgeInsets.only(bottom: 6.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
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
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    _attachmentFileName!,
                    style: AppTextStyles.body(
                      colors.textPrimary,
                      fontSize: 13.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: _removeAttachment,
                  child: Icon(Icons.close, color: colors.error, size: 16.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
        ],
        if (_attachmentFileName == null)
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: colors.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: colors.primaryBlue, size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'Pilih File',
                    style: AppTextStyles.body(
                      colors.primaryBlue,
                      fontSize: 13.sp,
                    ),
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
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
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
            padding: EdgeInsets.symmetric(vertical: 12.h),
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
                  widget.existingOvertime != null
                      ? 'Simpan Perubahan'
                      : 'Ajukan Lembur',
                  style: AppTextStyles.button(Colors.white),
                ),
        ),
      ),
    );
  }
}
