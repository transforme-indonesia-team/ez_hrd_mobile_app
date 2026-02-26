import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/data/services/attendance_service.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/screens/koreksi_kehadiran_review_screen.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/file_picker_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class FormKoreksiKehadiranScreen extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? employeeProfile;
  final String? employeeName;

  const FormKoreksiKehadiranScreen({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.employeeProfile,
    this.employeeName,
  });

  @override
  State<FormKoreksiKehadiranScreen> createState() =>
      _FormKoreksiKehadiranScreenState();
}

class _FormKoreksiKehadiranScreenState
    extends State<FormKoreksiKehadiranScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  DateTime? _startDate;
  DateTime? _endDate;
  File? _attachmentFile;
  String? _attachmentFileName;
  bool _isLoading = false;

  static const int _maxFileSizeBytes = 1 * 1024 * 1024; // 1MB

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate ?? DateTime.now();
    _endDate = widget.initialEndDate ?? DateTime.now();
  }

  Future<void> _selectDate({required bool isStart}) async {
    final now = DateTime.now();
    final firstAllowed = isStart
        ? DateTime(2020)
        : (_startDate ?? DateTime(2020)); // End date can't be before start
    final lastAllowed = isStart
        ? (_endDate ?? DateTime(2030))
        : DateTime(2030); // Start date can't be after end
    final initialDate = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstAllowed)
          ? firstAllowed
          : initialDate,
      firstDate: firstAllowed,
      lastDate: lastAllowed,
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
          // Auto-adjust end date if before start
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
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

  Future<void> _onLanjut() async {
    if (_startDate == null || _endDate == null) {
      context.showErrorSnackbar('Silakan pilih tanggal mulai dan berakhir');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      context.showErrorSnackbar(
        'Tanggal berakhir tidak boleh sebelum tanggal mulai',
      );
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null || user.employeeId == null) {
      context.showErrorSnackbar('User tidak ditemukan');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AttendanceService()
          .getScheduleCorrectionByEmployee(
            startDate: _startDate!,
            endDate: _endDate!,
            employeeId: user.employeeId!,
          );

      if (!mounted) return;

      // Parse shifts from response (post returns { original: { records: ... } })
      final records = response['original']?['records'] as Map<String, dynamic>?;
      final shifts = records?['shifts'] as List? ?? [];
      final employeeProfile =
          (records?['profile'] as String?) ?? widget.employeeProfile;
      final employeeName =
          (records?['employee_name'] as String?) ?? widget.employeeName;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KoreksiKehadiranReviewScreen(
            startDate: _startDate!,
            endDate: _endDate!,
            attachmentFile: _attachmentFile,
            attachmentFileName: _attachmentFileName,
            scheduleShifts: shifts,
            employeeProfile: employeeProfile,
            employeeName: employeeName,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar('Gagal memuat data jadwal: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          'Form Koreksi Kehadiran',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Diminta untuk
            _buildLabel(colors, 'Diminta untuk'),
            SizedBox(height: 6.h),
            _buildReadOnlyField(colors, value: user?.name ?? 'User'),
            SizedBox(height: 20.h),

            // Rentang Tanggal
            _buildSectionHeader(colors, 'RENTANG TANGGAL'),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(colors, 'Mulai'),
                      SizedBox(height: 6.h),
                      _buildDateField(
                        colors,
                        date: _startDate,
                        onTap: () => _selectDate(isStart: true),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: Text(
                    '  —  ',
                    style: AppTextStyles.body(colors.textSecondary),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(colors, 'Berakhir'),
                      SizedBox(height: 6.h),
                      _buildDateField(
                        colors,
                        date: _endDate,
                        onTap: () => _selectDate(isStart: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Lampiran
            _buildLabel(colors, 'Lampiran'),
            SizedBox(height: 6.h),
            _buildAttachmentSection(colors),
            SizedBox(height: 6.h),
            Text(
              'Berkas yang Didukung: doc,jpg,png,pdf max 1MB',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(colors),
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────

  Widget _buildLabel(ThemeColors colors, String text) {
    return Text(
      text,
      style: AppTextStyles.body(colors.textSecondary, fontSize: 13.sp),
    );
  }

  Widget _buildSectionHeader(ThemeColors colors, String text) {
    return Row(
      children: [
        Text(
          text,
          style: AppTextStyles.caption(
            colors.textSecondary,
          ).copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
        ),
        SizedBox(width: 10.w),
        Expanded(child: Divider(color: colors.divider)),
      ],
    );
  }

  Widget _buildReadOnlyField(ThemeColors colors, {required String value}) {
    return Container(
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
              value,
              style: AppTextStyles.body(colors.textPrimary, fontSize: 14.sp),
            ),
          ),
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

  Widget _buildAttachmentSection(ThemeColors colors) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: colors.divider,
          style: _attachmentFileName == null
              ? BorderStyle.none
              : BorderStyle.solid,
        ),
      ),
      child: _attachmentFileName != null
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
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
            )
          : GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: colors.divider,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 12.w),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: colors.primaryBlue,
                            size: 18.sp,
                          ),
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
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBottomButton(ThemeColors colors) {
    return Container(
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _onLanjut,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primaryBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: colors.primaryBlue.withValues(alpha: 0.5),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text('Lanjut', style: AppTextStyles.button(Colors.white)),
        ),
      ),
    );
  }
}
