import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';
import 'package:hrd_app/data/services/attendance_correction_service.dart';
import 'package:hrd_app/data/services/reservation_service.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/widgets/form_detail_bottom_sheet.dart';
import 'package:provider/provider.dart';

import 'package:hrd_app/data/models/attendance_correction_model.dart';

class KoreksiKehadiranReviewScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final File? attachmentFile;
  final String? attachmentFileName;
  final List<dynamic> scheduleShifts;
  final String? employeeProfile;
  final String? employeeName;
  final AttendanceCorrectionModel? existingCorrection;

  const KoreksiKehadiranReviewScreen({
    super.key,
    required this.startDate,
    required this.endDate,
    this.attachmentFile,
    this.attachmentFileName,
    this.scheduleShifts = const [],
    this.employeeProfile,
    this.employeeName,
    this.existingCorrection,
  });

  @override
  State<KoreksiKehadiranReviewScreen> createState() =>
      _KoreksiKehadiranReviewScreenState();
}

class _KoreksiKehadiranReviewScreenState
    extends State<KoreksiKehadiranReviewScreen> {
  late List<CorrectionDetailEntry> _details;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _generateDetailEntries();
  }

  void _generateDetailEntries() {
    _details = [];

    // Build a map from API shifts: date -> shift data
    final shiftMap = <String, Map<String, dynamic>>{};
    for (final shift in widget.scheduleShifts) {
      if (shift is Map<String, dynamic>) {
        final date = shift['date'] as String?;
        if (date != null) {
          shiftMap[date] = shift;
        }
      }
    }

    // Generate one entry per date in the range
    var current = widget.startDate;
    while (!current.isAfter(widget.endDate)) {
      final dateKey = FormatDate.apiFormat(current);
      final shift = shiftMap[dateKey];

      if (shift != null) {
        final shiftData = shift['shift_data'] as Map<String, dynamic>?;
        final attendance = shift['attendance'] as Map<String, dynamic>?;

        // Try to find existing detail if editing
        AttendanceCorrectionDetailModel? existingDetail;
        if (widget.existingCorrection != null) {
          try {
            existingDetail = widget.existingCorrection!.details.firstWhere(
              (d) => d.dateScheduleCorrection == dateKey,
            );
          } catch (e) {
            existingDetail = null;
          }
        }

        _details.add(
          CorrectionDetailEntry(
            date: current,
            shiftCode: shiftData?['shift_name'] as String?,
            shiftId:
                existingDetail?.shiftDailyCodeCorrection ??
                shiftData?['shift_daily_id'] as String?,
            checkInBefore: attendance?['check_in'] as String?,
            checkOutBefore: attendance?['check_out'] as String?,
            checkInAfter: existingDetail?.checkInAfterCorrection,
            checkOutAfter: existingDetail?.checkOutAfterCorrection,
            remark: existingDetail?.remarkAttendanceCorrection,
          ),
        );
      } else {
        _details.add(CorrectionDetailEntry(date: current));
      }

      current = current.add(const Duration(days: 1));
    }
  }

  Future<void> _editDetail(int index) async {
    final result = await FormDetailBottomSheet.show(
      context,
      entry: _details[index],
    );

    if (result == null) return; // Dismissed, do nothing

    if (result.deleted) {
      setState(() => _details.removeAt(index));
    } else if (result.entry != null) {
      setState(() => _details[index] = result.entry!);
    }
  }

  void _deleteDetail(int index) {
    setState(() => _details.removeAt(index));
  }

  Future<void> _submit() async {
    if (_details.isEmpty) {
      context.showErrorSnackbar('Tidak ada detail koreksi');
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null || user.employeeId == null) {
      context.showErrorSnackbar('User tidak ditemukan');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Step 1: Get reservation number
      final reservationResponse = await ReservationService()
          .getReservationNumber(reservationType: 'ATTENDANCE');
      final records =
          reservationResponse['original']?['records'] as Map<String, dynamic>?;
      final requestNumber = records?['request_number'] as String?;

      if (requestNumber == null || requestNumber.isEmpty) {
        throw Exception('Gagal mendapatkan nomor permintaan');
      }

      // Step 2: Build FormData
      final Map<String, dynamic> formDataMap = {
        'attendance_correction_request_no': requestNumber,
        'start_date_attendance_correction': FormatDate.apiFormat(
          widget.startDate,
        ),
        'end_date_attendance_correction': FormatDate.apiFormat(widget.endDate),
        'employee_id': user.employeeId!,
      };

      // Add detail entries
      for (int i = 0; i < _details.length; i++) {
        final d = _details[i];
        final prefix = 'attendance_correction_details[$i]';
        formDataMap['$prefix[date_schedule_correction]'] = FormatDate.apiFormat(
          d.date,
        );
        formDataMap['$prefix[shift_daily_code_correction]'] = d.shiftId ?? '';
        formDataMap['$prefix[shift_daily_code_before]'] = d.shiftCode ?? '';
        formDataMap['$prefix[check_in_before_correction]'] =
            d.checkInBefore ?? '';
        formDataMap['$prefix[check_out_before_correction]'] =
            d.checkOutBefore ?? '';
        formDataMap['$prefix[check_in_after_correction]'] =
            d.checkInAfter ?? '';
        formDataMap['$prefix[check_out_after_correction]'] =
            d.checkOutAfter ?? '';
        formDataMap['$prefix[remark_attendance_correction]'] = d.remark ?? '';
      }

      // Add file attachment if exists
      if (widget.attachmentFile != null) {
        formDataMap['file_attachment_correction'] =
            await MultipartFile.fromFile(
              widget.attachmentFile!.path,
              filename: widget.attachmentFileName,
            );
      }

      // Step 3: Submit
      if (widget.existingCorrection != null &&
          widget.existingCorrection!.id != null) {
        await AttendanceCorrectionService().updateAttendanceCorrection(
          widget.existingCorrection!.id!,
          formDataMap,
        );
      } else {
        await AttendanceCorrectionService().storeAttendanceCorrection(
          formDataMap,
        );
      }

      if (mounted) {
        context.showSuccessSnackbar(
          widget.existingCorrection != null
              ? 'Permintaan koreksi kehadiran berhasil diperbarui'
              : 'Permintaan koreksi kehadiran berhasil diajukan',
        );
        // Pop back to list screen
        Navigator.of(context)
          ..pop() // review screen
          ..pop(true); // form screen → return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar('Gagal mengajukan koreksi: ${e.toString()}');
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
          'Koreksi Kehadiran',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Employee info ──
            Text(
              'Diminta untuk',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                UserAvatar(
                  avatarUrl: widget.employeeProfile,
                  name: widget.employeeName ?? user?.name,
                  size: 42,
                  fontSize: 14,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.employeeName ?? user?.name ?? '-',
                        style: AppTextStyles.bodyMedium(
                          colors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'LEADER',
                        style: AppTextStyles.caption(colors.primaryBlue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // ── Date range ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal Mulai',
                        style: AppTextStyles.caption(colors.textSecondary),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        FormatDate.shortDateWithYear(widget.startDate),
                        style: AppTextStyles.bodyMedium(
                          colors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal Berakhir',
                        style: AppTextStyles.caption(colors.textSecondary),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        FormatDate.shortDateWithYear(widget.endDate),
                        style: AppTextStyles.bodyMedium(
                          colors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // ── Detail section ──
            Row(
              children: [
                Text(
                  'DETAIL',
                  style: AppTextStyles.caption(
                    colors.textSecondary,
                  ).copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 10.w),
                Expanded(child: Divider(color: colors.divider)),
              ],
            ),
            SizedBox(height: 12.h),

            if (_details.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Text(
                    'Semua detail telah dihapus',
                    style: AppTextStyles.body(colors.textSecondary),
                  ),
                ),
              )
            else
              ..._details.asMap().entries.map((entry) {
                final index = entry.key;
                final detail = entry.value;
                return _buildDetailCard(colors, detail, index);
              }),

            SizedBox(height: 40.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(colors),
    );
  }

  Widget _buildDetailCard(
    ThemeColors colors,
    CorrectionDetailEntry detail,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: date + times
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.displayDate,
                  style: AppTextStyles.bodyMedium(
                    colors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2.h),
                Text(
                  detail.isEdited
                      ? '${detail.displayCheckInAfter} | ${detail.displayCheckOutAfter}'
                      : '${detail.displayCheckInBefore} | ${detail.displayCheckOutBefore}',
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
              ],
            ),
          ),

          // Middle: shift + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.displayShift,
                  style: AppTextStyles.bodyMedium(
                    colors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  detail.statusText,
                  style: AppTextStyles.caption(
                    detail.isEdited
                        ? Colors.green.shade600
                        : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Right: edit + delete icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _editDetail(index),
                child: Icon(
                  Icons.edit_outlined,
                  color: colors.textSecondary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: () => _deleteDetail(index),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade400,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(ThemeColors colors) {
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
      child: Row(
        children: [
          // Expanded(
          //   child: OutlinedButton(
          //     onPressed: _isSubmitting
          //         ? null
          //         : () {
          //             context.showInfoSnackbar('Draf belum tersedia');
          //           },
          //     style: OutlinedButton.styleFrom(
          //       foregroundColor: colors.primaryBlue,
          //       side: BorderSide(color: colors.primaryBlue),
          //       padding: EdgeInsets.symmetric(vertical: 12.h),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8.r),
          //       ),
          //     ),
          //     child: Text(
          //       'Draf',
          //       style: AppTextStyles.button(colors.primaryBlue),
          //     ),
          //   ),
          // ),
          // SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: colors.primaryBlue.withValues(
                  alpha: 0.5,
                ),
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
                  : Text('Ajukan', style: AppTextStyles.button(Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
