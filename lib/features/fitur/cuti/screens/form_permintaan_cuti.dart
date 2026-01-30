import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/data/models/employee_leave_balance_model.dart';
import 'package:hrd_app/data/models/employee_leave_relation_response.dart';
import 'package:hrd_app/data/models/leave_employee_model.dart';
import 'package:hrd_app/data/services/employee_service.dart';
import 'package:hrd_app/data/services/leave_service.dart';
import 'package:hrd_app/data/services/reservation_service.dart';
import 'package:hrd_app/features/fitur/cuti/widgets/leave_type_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/file_picker_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class FormPermintaanCutiScreeen extends StatefulWidget {
  final LeaveEmployeeModel? existingLeave;

  const FormPermintaanCutiScreeen({super.key, this.existingLeave});

  @override
  State<FormPermintaanCutiScreeen> createState() =>
      _FormPermintaanCutiScreeenState();
}

class _FormPermintaanCutiScreeenState extends State<FormPermintaanCutiScreeen> {
  bool _isLoadingLeaveTypes = true;
  String? _errorMessage;

  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  DateTime? _startDate;
  DateTime? _endDate;

  List<EmployeeLeaveBalanceModel> _leaveTypes = [];
  EmployeeLeaveBalanceModel? _selectedLeaveType;

  File? _attachmentFile;
  String? _attachmentFileName;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    if (widget.existingLeave != null) {
      _populateExistingData();
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoadingLeaveTypes = true;
      _errorMessage = null; // Reset error saat fetch ulang
    });
    try {
      final response = await EmployeeService().getRelation(relation: 'LEAVE');
      final parsedResponse = EmployeeLeaveRelationResponse.fromJson(response);

      if (mounted) {
        setState(() {
          _isLoadingLeaveTypes = false;
          _leaveTypes = parsedResponse.leaveBalances;
          if (!parsedResponse.isSuccess) {
            _errorMessage = parsedResponse.message ?? 'Gagal memuat data cuti';
          }

          // Auto-select leave type jika edit mode
          if (widget.existingLeave != null && _leaveTypes.isNotEmpty) {
            final existingLeaveTypeId = widget.existingLeave!.leaveTypeId;
            if (existingLeaveTypeId != null) {
              _selectedLeaveType = _leaveTypes.firstWhere(
                (type) =>
                    type.leaveTypeId?.toLowerCase() ==
                        existingLeaveTypeId.toLowerCase() ||
                    type.id.toLowerCase() == existingLeaveTypeId.toLowerCase(),
                orElse: () => _leaveTypes.first,
              );
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLeaveTypes = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _populateExistingData() {
    final leave = widget.existingLeave!;

    // Parse start date
    if (leave.startLeave != null) {
      try {
        _startDate = DateFormat('yyyy-MM-dd').parse(leave.startLeave!);
      } catch (e) {
        _startDate = DateTime.now();
      }
    }

    // Parse end date
    if (leave.endLeave != null) {
      try {
        _endDate = DateFormat('yyyy-MM-dd').parse(leave.endLeave!);
      } catch (e) {
        _endDate = DateTime.now();
      }
    }

    // Set description
    if (leave.remarkLeave != null) {
      _descriptionController.text = leave.remarkLeave!;
    }

    // Set file name if exists
    if (leave.hasAttachment) {
      _attachmentFileName = leave.fileAttachmentLeave ?? 'File terlampir';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
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
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
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
      setState(() => _endDate = picked);
    }
  }

  Future<void> _selectLeaveType() async {
    final selected = await LeaveTypeBottomSheet.show(
      context,
      types: _leaveTypes,
      selectedType: _selectedLeaveType,
      isLoading: _isLoadingLeaveTypes,
    );

    if (selected != null) {
      setState(() => _selectedLeaveType = selected);
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

  Future<void> _submit() async {
    if (_selectedLeaveType == null) {
      context.showErrorSnackbar('Silakan pilih jenis cuti');
      return;
    }

    if (_startDate == null || _endDate == null) {
      context.showErrorSnackbar('Silakan pilih tanggal mulai dan berakhir');
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
      context.showErrorSnackbar('Employee ID tidak ditemukan');
      return;
    }

    if (companyId.isEmpty) {
      context.showErrorSnackbar('Company tidak ditemukan');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final isEditMode = widget.existingLeave != null;

      if (isEditMode) {
        // Update existing leave
        await LeaveService().updateLeaveEmployee(
          leaveId: widget.existingLeave!.id,
          leaveRequestNo: widget.existingLeave!.displayRequestNo,
          startLeave: DateFormat('yyyy-MM-dd').format(_startDate!),
          endLeave: DateFormat('yyyy-MM-dd').format(_endDate!),
          leaveTypeId:
              _selectedLeaveType?.leaveTypeId ??
              _selectedLeaveType?.id ??
              widget.existingLeave!.leaveTypeId ??
              '',
          remarkLeave: _descriptionController.text.trim(),
          employeeId: user.employeeId!,
          fileAttachment: _attachmentFile,
        );

        if (mounted) {
          context.showSuccessSnackbar('Perubahan berhasil disimpan');
          Navigator.pop(context, true);
        }
      } else {
        // Create new leave
        // Step 1: Get reservation number from API
        final reservationResponse = await ReservationService()
            .getReservationNumber(
              reservationType: 'LEAVE',
              companyId: companyId,
            );

        final records =
            reservationResponse['original']?['records']
                as Map<String, dynamic>?;
        final requestNumber = records?['request_number'] as String?;

        if (requestNumber == null || requestNumber.isEmpty) {
          throw Exception('Gagal mendapatkan nomor permintaan cuti');
        }

        // Step 2: Submit leave request with request number
        await LeaveService().createLeaveEmployee(
          leaveRequestNo: requestNumber,
          startLeave: DateFormat('yyyy-MM-dd').format(_startDate!),
          endLeave: DateFormat('yyyy-MM-dd').format(_endDate!),
          leaveTypeId:
              _selectedLeaveType!.leaveTypeId ?? _selectedLeaveType!.id,
          remarkLeave: _descriptionController.text.trim(),
          employeeId: user.employeeId!,
          fileAttachment: _attachmentFile,
        );

        if (mounted) {
          context.showSuccessSnackbar('Permintaan cuti berhasil diajukan');
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        // Clean up error message
        String errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.replaceFirst('Exception: ', '');
        }
        final action = widget.existingLeave != null
            ? 'menyimpan perubahan'
            : 'mengajukan cuti';
        context.showErrorSnackbar('Gagal $action: $errorMsg');
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
          widget.existingLeave != null
              ? 'Edit Permintaan Cuti'
              : 'Permintaan Cuti',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(colors, 'Diminta untuk'),
            SizedBox(height: 6.h),
            _buildReadOnlyField(
              colors,
              value: user?.name ?? 'User',
              icon: Icons.person_outline,
            ),
            SizedBox(height: 10.h),

            _buildLabel(colors, 'Jenis Cuti'),
            SizedBox(height: 6.h),
            _buildLeaveTypeDropdown(colors),
            if (_selectedLeaveType != null) ...[
              SizedBox(height: 6.h),
              _buildValidityInfo(colors, _selectedLeaveType!),
            ],
            SizedBox(height: 10.h),

            _buildLabel(colors, 'Tanggal Mulai'),
            SizedBox(height: 6.h),
            _buildDateField(colors, date: _startDate, onTap: _selectStartDate),
            SizedBox(height: 10.h),

            _buildLabel(colors, 'Tanggal Berakhir'),
            SizedBox(height: 6.h),
            _buildDateField(colors, date: _endDate, onTap: _selectEndDate),
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
      style: AppTextStyles.body(
        colors.textPrimary,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
      ),
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

  Widget _buildTextField(ThemeColors colors) {
    return TextField(
      controller: _descriptionController,
      maxLines: 3,
      maxLength: 30,
      decoration: InputDecoration(
        hintText: 'Tulis Alasan Cuti...',
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
            color: Colors.black.withOpacity(0.05),
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
            disabledBackgroundColor: colors.primaryBlue.withOpacity(0.5),
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
                  widget.existingLeave != null
                      ? 'Simpan Perubahan'
                      : 'Ajukan Cuti',
                  style: AppTextStyles.button(Colors.white),
                ),
        ),
      ),
    );
  }

  /// Widget dropdown untuk memilih jenis cuti dengan loading state
  Widget _buildLeaveTypeDropdown(ThemeColors colors) {
    // Tampilkan loading jika masih memuat
    if (_isLoadingLeaveTypes) {
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
                'Memuat jenis cuti...',
                style: AppTextStyles.body(
                  colors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
            ),
            SizedBox(
              width: 14.w,
              height: 14.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primaryBlue,
              ),
            ),
          ],
        ),
      );
    }

    // Tampilkan error jika ada masalah saat memuat
    if (_errorMessage != null) {
      return GestureDetector(
        onTap: _fetchData, // Tap untuk retry
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: colors.error),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Gagal memuat jenis cuti',
                  style: AppTextStyles.body(colors.error, fontSize: 13.sp),
                ),
              ),
              Icon(Icons.refresh, color: colors.error, size: 18.sp),
            ],
          ),
        ),
      );
    }

    return _buildDropdownField(
      colors,
      value: _selectedLeaveType?.displayLeaveTypeName,
      hint: 'Pilih jenis cuti',
      onTap: _selectLeaveType,
      onClear: _selectedLeaveType != null
          ? () => setState(() => _selectedLeaveType = null)
          : null,
    );
  }

  Widget _buildValidityInfo(
    ThemeColors colors,
    EmployeeLeaveBalanceModel leaveType,
  ) {
    // Gunakan helper dari model untuk parse date
    final startDate = leaveType.parsedStartValidDate;
    final endDate = leaveType.parsedEndValidDate;

    // Format dates using FormatDate helper
    String formattedDateRange = '-';

    if (startDate != null && endDate != null) {
      formattedDateRange = FormatDate.dateRange(startDate, endDate);
    } else {
      // Fallback ke string mentah jika parsing gagal
      final startStr = leaveType.startValidDateLeave ?? '';
      final endStr = leaveType.endValidDateLeave ?? '';
      if (startStr.isNotEmpty && endStr.isNotEmpty) {
        formattedDateRange = '$startStr - $endStr';
      }
    }

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validitas',
                  style: AppTextStyles.body(
                    colors.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  formattedDateRange,
                  style: AppTextStyles.body(
                    colors.primaryBlue,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Sisa',
                style: AppTextStyles.body(
                  colors.textPrimary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                leaveType.displayRemainingLeave,
                style: AppTextStyles.body(colors.primaryBlue, fontSize: 13.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
