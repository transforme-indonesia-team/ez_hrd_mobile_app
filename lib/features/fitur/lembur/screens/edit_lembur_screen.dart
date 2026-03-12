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
import 'package:hrd_app/features/fitur/lembur/widgets/detail_lembur_widgets.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/file_picker_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/overtime_type_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class EditLemburScreen extends StatefulWidget {
  final OvertimeEmployeeModel existingOvertime;

  const EditLemburScreen({super.key, required this.existingOvertime});

  @override
  State<EditLemburScreen> createState() => _EditLemburScreenState();
}

class _EditLemburScreenState extends State<EditLemburScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  DateTime? _overtimeDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  OvertimeTypeModel? _selectedOvertimeType;

  File? _attachmentFile;
  String? _attachmentFileName;

  bool _isSubmitting = false;

  final List<OvertimeTypeModel> _overtimeTypes = const [
    OvertimeTypeModel(id: '1', name: 'Jam Lembur'),
    OvertimeTypeModel(id: '2', name: 'Cuti Tambahan'),
  ];

  @override
  void initState() {
    super.initState();
    _populateExistingData();
  }

  void _populateExistingData() {
    final overtime = widget.existingOvertime;

    if (overtime.dateOvertime != null) {
      try {
        _overtimeDate = DateFormat('yyyy-MM-dd').parse(overtime.dateOvertime!);
      } catch (e) {
        _overtimeDate = DateTime.now();
      }
    }

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

    if (overtime.remarkOvertime != null) {
      _descriptionController.text = overtime.remarkOvertime!;
    }

    if (overtime.hasAttachment) {
      _attachmentFileName = overtime.fileNameOvertime ?? 'File terlampir';
    }

    _selectedOvertimeType = _overtimeTypes.first;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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
          if (image != null) await _setAttachment(File(image.path), image.name);
          break;
        case FilePickerType.gallery:
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
          );
          if (image != null) await _setAttachment(File(image.path), image.name);
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

  static const int _maxFileSizeBytes = 1 * 1024 * 1024;

  Future<void> _setAttachment(File file, String fileName) async {
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
  }

  void _removeAttachment() {
    setState(() {
      _attachmentFile = null;
      _attachmentFileName = null;
    });
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '--:--';
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
    if (user == null || user.employeeId == null) {
      context.showErrorSnackbar('User tidak ditemukan');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await OvertimeService().updateOvertime(
        overtimeId: widget.existingOvertime.id,
        overtimeRequestNo: widget.existingOvertime.displayOvertimeRequestNo,
        dateOvertime: DateFormat('yyyy-MM-dd').format(_overtimeDate!),
        startOvertime: _formatTimeOfDay(_startTime),
        endOvertime: _formatTimeOfDay(_endTime),
        remarkOvertime: _descriptionController.text.trim(),
        fileAttachment: _attachmentFile,
        employeeId: user.employeeId!,
      );

      if (mounted) {
        context.showSuccessSnackbar('Perubahan berhasil diajukan');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar('Gagal menyimpan perubahan: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showEditTimeDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = context.colors;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              padding: EdgeInsets.fromLTRB(
                16.w,
                24.h,
                16.w,
                MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Waktu Lembur',
                        style: AppTextStyles.h4(colors.textPrimary),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: colors.textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(colors, 'Mulai'),
                            SizedBox(height: 6.h),
                            GestureDetector(
                              onTap: () async {
                                await _selectTime(true);
                                setModalState(() {}); // Trigger modal rebuild
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: colors.divider),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _formatTimeOfDay(_startTime),
                                        style: AppTextStyles.body(
                                          colors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.access_time,
                                      size: 16.sp,
                                      color: colors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(colors, 'Berakhir'),
                            SizedBox(height: 6.h),
                            GestureDetector(
                              onTap: () async {
                                await _selectTime(false);
                                setModalState(() {}); // Trigger modal rebuild
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: colors.divider),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _formatTimeOfDay(_endTime),
                                        style: AppTextStyles.body(
                                          colors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.access_time,
                                      size: 16.sp,
                                      color: colors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryBlue,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Simpan Waktu',
                        style: AppTextStyles.button(Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final overtime = widget.existingOvertime;

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
          'Rincian Form Lembur',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            UserInfoItem(
              label: 'Permintaan Untuk',
              name: overtime.displayEmployeeName,
              role: 'EMPLOYEE',
              photoUrl: null, // If available in overtime model
            ),
            SizedBox(height: 16.h),

            // Tanggal
            Row(
              children: [
                Expanded(
                  child: LabelValueColumn(
                    label: 'Tanggal Mulai',
                    value: _overtimeDate != null
                        ? FormatDate.shortDateWithYear(_overtimeDate!)
                        : '-',
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: LabelValueColumn(
                    label: 'Tanggal Berakhir',
                    value: _overtimeDate != null
                        ? FormatDate.shortDateWithYear(_overtimeDate!)
                        : '-',
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Nomor Permintaan
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nomor Permintaan',
                  style: AppTextStyles.caption(
                    colors.textSecondary,
                  ).copyWith(fontSize: 12.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  overtime.displayOvertimeRequestNo,
                  style: AppTextStyles.body(
                    colors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 16.sp),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Divider(color: colors.divider, height: 1),
            SizedBox(height: 16.h),

            // Editable Fields
            _buildLabel(colors, 'Tipe Lembur'),
            SizedBox(height: 6.h),
            _buildDropdownField(
              colors,
              value: _selectedOvertimeType?.displayName,
              hint: 'Pilih tipe lembur',
              onTap: _selectOvertimeType,
            ),
            SizedBox(height: 16.h),

            _buildLabel(colors, 'Keterangan'),
            SizedBox(height: 6.h),
            _buildTextField(colors),
            SizedBox(height: 16.h),

            Divider(color: colors.divider, height: 1),
            SizedBox(height: 16.h),

            _buildAttachmentSection(colors),
            SizedBox(height: 6.h),
            Text(
              'Berkas yang Didukung: txt,doc,docx,jpg,png,gif,xls,pdf',
              style: AppTextStyles.caption(
                colors.textSecondary,
              ).copyWith(fontSize: 11.sp),
            ),
            SizedBox(height: 24.h),

            // DETAIL SECTION
            DetailSectionHeader(title: 'DETAIL'),
            Divider(color: colors.divider, height: 1),
            SizedBox(height: 16.h),

            // Row date with edit icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _overtimeDate != null
                      ? DateFormat('d MMM', 'id_ID').format(_overtimeDate!)
                      : '-',
                  style: AppTextStyles.h4(colors.textPrimary),
                ),
                GestureDetector(
                  onTap: _showEditTimeDialog,
                  child: Icon(
                    Icons.edit_outlined,
                    color: colors.primaryBlue,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Shift info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lembur 1',
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
                Text(
                  'Shift Flexible',
                  style: AppTextStyles.caption(colors.textPrimary),
                ), // Or use actual shift name if available
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mulai: ${_formatTimeOfDay(_startTime)} | Berakhir: ${_formatTimeOfDay(_endTime)}',
                  style: AppTextStyles.body(colors.textPrimary),
                ),
                Text(
                  'Memperbarui',
                  style: AppTextStyles.body(colors.textPrimary),
                ),
              ],
            ),

            SizedBox(height: 40.h),

            // Ajukan Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primaryBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: colors.primaryBlue.withValues(
                    alpha: 0.5,
                  ),
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
                    : Text('Ajukan', style: AppTextStyles.button(Colors.white)),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(ThemeColors colors, String text) {
    return Text(
      text,
      style: AppTextStyles.body(colors.textSecondary, fontSize: 13.sp),
    );
  }

  Widget _buildDropdownField(
    ThemeColors colors, {
    required String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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

  Widget _buildTextField(ThemeColors colors) {
    return TextField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Keterangan',
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
        contentPadding: EdgeInsets.all(12.w),
      ),
      style: AppTextStyles.body(colors.textPrimary, fontSize: 13.sp),
    );
  }

  Widget _buildAttachmentSection(ThemeColors colors) {
    if (_attachmentFileName != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          children: [
            Icon(Icons.attachment, color: colors.textSecondary, size: 16.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                _attachmentFileName!,
                style: AppTextStyles.body(colors.textPrimary, fontSize: 13.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: _removeAttachment,
              child: Icon(Icons.close, color: colors.error, size: 18.sp),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: 140.w, // Limit width to match design
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: colors.primaryBlue,
            style: BorderStyle.solid,
          ), // In a real app we might use dotted_border package, using solid here as fallback
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: colors.primaryBlue, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              'Pilih File',
              style: AppTextStyles.body(
                colors.primaryBlue,
              ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }
}
