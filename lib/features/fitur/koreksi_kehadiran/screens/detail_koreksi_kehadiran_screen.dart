import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';
import 'package:hrd_app/data/models/attendance_correction_model.dart';
import 'package:hrd_app/data/services/attendance_correction_service.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/detail_lembur_widgets.dart';

class DetailKoreksiKehadiranScreen extends StatefulWidget {
  final String correctionId;

  const DetailKoreksiKehadiranScreen({super.key, required this.correctionId});

  @override
  State<DetailKoreksiKehadiranScreen> createState() =>
      _DetailKoreksiKehadiranScreenState();
}

class _DetailKoreksiKehadiranScreenState
    extends State<DetailKoreksiKehadiranScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  AttendanceCorrectionModel? _data;

  // Track which detail items have their "Kehadiran Aktual" expanded
  final Set<int> _expandedKehadiranIndices = {};

  // Track PNI/PNO state per detail index
  final Map<int, bool> _pniStates = {};
  final Map<int, bool> _pnoStates = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await AttendanceCorrectionService()
          .getAttendanceCorrectionById(widget.correctionId);

      final records = response['original'];

      if (records == null || records is List || records['records'] == null) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Data tidak ditemukan';
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _data = AttendanceCorrectionModel.fromJson(
            records['records'] as Map<String, dynamic>,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching detail koreksi kehadiran: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Terjadi kesalahan saat memuat data';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelCorrection() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await AttendanceCorrectionService()
          .deleteAttendanceCorrection(widget.correctionId);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      final records = response['original'];
      final isSuccess = records['status'] == true || records['code'] == 200;

      if (isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                records['message'] ?? 'Koreksi kehadiran berhasil dibatalkan',
              ),
              backgroundColor: ColorPalette.green600,
            ),
          );
          Navigator.pop(context, true); // true = refresh list
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                records['message'] ?? 'Gagal membatalkan koreksi kehadiran',
              ),
              backgroundColor: ColorPalette.red500,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ColorPalette.red500,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
          'Detail Permintaan',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: _buildContent(colors),
      bottomNavigationBar: _isLoading || _hasError || _data == null
          ? null
          : _buildBottomButton(colors),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.sp, color: colors.divider),
            SizedBox(height: 16.h),
            Text(
              _errorMessage ?? 'Data tidak tersedia',
              style: AppTextStyles.body(colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                _fetchData();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primaryBlue,
                side: BorderSide(color: colors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return _buildBody(colors);
  }

  Widget _buildBody(ThemeColors colors) {
    final data = _data!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Section ──
          _buildHeaderSection(colors, data),
          SizedBox(height: 16.h),

          // ── Correction Details ──
          ...data.details.asMap().entries.map((entry) {
            final index = entry.key;
            final detail = entry.value;
            return Column(
              children: [
                _buildCorrectionDetailCard(colors, data, detail, index),
                SizedBox(height: 16.h),
              ],
            );
          }),

          // ── Daftar Persetujuan ──
          if (data.approvers.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildApprovalSection(colors, data),
          ],

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // ─── Header Section ───────────────────────────────────────────
  Widget _buildHeaderSection(
    ThemeColors colors,
    AttendanceCorrectionModel data,
  ) {
    return Container(
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nomor Permintaan + Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabelValueColumn(
                  label: 'Nomor Permintaan',
                  value: data.displayRequestNo,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(width: 12.w),
              _buildStatusBadge(colors, data.displayStatus),
            ],
          ),
          SizedBox(height: 16.h),

          // Permintaan Oleh & Permintaan untuk
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: UserInfoItem(
                  label: 'Permintaan Oleh',
                  name: data.displayCreatedBy,
                  role: data.companyName ?? '-',
                  photoUrl: data.createdByPhoto,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: UserInfoItem(
                  label: 'Permintaan untuk',
                  name: data.displayEmployeeName,
                  role: data.companyName ?? '-',
                  photoUrl: data.profile,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Tanggal Mulai & Tanggal Berakhir
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabelValueColumn(
                  label: 'Tanggal Mulai',
                  value: data.displayStartDate,
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    size: 14.sp,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: LabelValueColumn(
                  label: 'Tanggal Berakhir',
                  value: data.displayEndDate,
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    size: 14.sp,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Correction Detail Card ───────────────────────────────────
  Widget _buildCorrectionDetailCard(
    ThemeColors colors,
    AttendanceCorrectionModel data,
    AttendanceCorrectionDetailModel detail,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header with badge
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Text(
              _formatDetailDate(detail.dateScheduleCorrection),
              style: AppTextStyles.bodyMedium(
                colors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),

          Divider(color: colors.divider, height: 1),

          // Sebelumnya Section
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Text(
              'Sebelumnya',
              style: AppTextStyles.bodySemiBold(colors.textPrimary),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shift',
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatShiftCode(detail.shiftDailyCodeBefore),
                  style: AppTextStyles.body(colors.textPrimary),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeColumn(
                        colors,
                        'Jam Masuk',
                        _formatTimeFromDatetime(detail.checkInBeforeCorrection),
                      ),
                    ),
                    Expanded(
                      child: _buildTimeColumn(
                        colors,
                        'Jam Keluar',
                        _formatTimeFromDatetime(
                          detail.checkOutBeforeCorrection,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Sesudahnya Section
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
            child: Text(
              'Sesudahnya',
              style: AppTextStyles.bodySemiBold(colors.textPrimary),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shift',
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatShiftCode(detail.shiftDailyCodeCorrection),
                  style: AppTextStyles.body(colors.textPrimary),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeColumn(
                        colors,
                        'Jam Masuk',
                        _formatTimeDateFromDatetime(
                          detail.checkInAfterCorrection,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildTimeColumn(
                        colors,
                        'Jam Keluar',
                        _formatTimeDateFromDatetime(
                          detail.checkOutAfterCorrection,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Kehadiran Aktual expandable
          _buildKehadiranAktualSection(colors, data, detail, index),

          // Status Lainnya section
          _buildStatusLainnya(colors, detail, index),

          // Keterangan
          if (detail.remarkAttendanceCorrection != null &&
              detail.remarkAttendanceCorrection!.isNotEmpty) ...[
            Divider(color: colors.divider, height: 1),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keterangan',
                    style: AppTextStyles.caption(colors.textSecondary),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    detail.remarkAttendanceCorrection!,
                    style: AppTextStyles.body(colors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeColumn(ThemeColors colors, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(colors.textSecondary)),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.bodyMedium(
            colors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ─── Kehadiran Aktual (Expandable) ────────────────────────────
  Widget _buildKehadiranAktualSection(
    ThemeColors colors,
    AttendanceCorrectionModel data,
    AttendanceCorrectionDetailModel detail,
    int index,
  ) {
    final isExpanded = _expandedKehadiranIndices.contains(index);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.backgroundDetail,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: colors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedKehadiranIndices.remove(index);
                } else {
                  _expandedKehadiranIndices.add(index);
                }
              });
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kehadiran Aktual',
                    style: AppTextStyles.bodyMedium(colors.textSecondary),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(color: colors.divider, height: 1),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDetailDate(detail.dateScheduleCorrection),
                    style: AppTextStyles.bodyMedium(
                      colors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Shift: ${_formatShiftLabel(detail.shiftDailyCodeCorrection, detail.dateScheduleCorrection)}',
                    style: AppTextStyles.caption(colors.textSecondary),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: AttendanceTimeCard(
                          label: 'Jam Masuk',
                          time: _formatTimeFromDatetime(
                            detail.checkInBeforeCorrection,
                          ),
                          hasError: detail.checkInBeforeCorrection == null,
                          avatar: UserAvatar(
                            avatarUrl: data.profile,
                            name: data.employeeName,
                            size: 36,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AttendanceTimeCard(
                          label: 'Jam Keluar',
                          time: _formatTimeFromDatetime(
                            detail.checkOutBeforeCorrection,
                          ),
                          hasError: detail.checkOutBeforeCorrection == null,
                          avatar: UserAvatar(
                            avatarUrl: data.profile,
                            name: data.employeeName,
                            size: 36,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Status Lainnya (PNI/PNO) ─────────────────────────────────
  Widget _buildStatusLainnya(
    ThemeColors colors,
    AttendanceCorrectionDetailModel detail,
    int index,
  ) {
    // Initialize from API on first render
    final status = detail.statusDetailAttendanceCorrection?.toUpperCase() ?? '';
    _pniStates.putIfAbsent(
      index,
      () => status == 'PNI' || status.contains('PNI'),
    );
    _pnoStates.putIfAbsent(
      index,
      () => status == 'PNO' || status.contains('PNO'),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Row(
        children: [
          Text(
            'Status Lainnya',
            style: AppTextStyles.bodySemiBold(colors.textPrimary),
          ),
          const Spacer(),
          // PNI checkbox
          SizedBox(
            width: 24.w,
            height: 24.w,
            child: Checkbox(
              value: _pniStates[index] ?? false,
              onChanged: (val) {
                setState(() => _pniStates[index] = val ?? false);
              },
              activeColor: colors.primaryBlue,
              side: BorderSide(color: colors.divider, width: 1.5),
            ),
          ),
          SizedBox(width: 4.w),
          Text('PNI', style: AppTextStyles.body(colors.textPrimary)),
          SizedBox(width: 16.w),
          // PNO checkbox
          SizedBox(
            width: 24.w,
            height: 24.w,
            child: Checkbox(
              value: _pnoStates[index] ?? false,
              onChanged: (val) {
                setState(() => _pnoStates[index] = val ?? false);
              },
              activeColor: colors.primaryBlue,
              side: BorderSide(color: colors.divider, width: 1.5),
            ),
          ),
          SizedBox(width: 4.w),
          Text('PNO', style: AppTextStyles.body(colors.textPrimary)),
        ],
      ),
    );
  }

  // ─── Approval Section ─────────────────────────────────────────
  Widget _buildApprovalSection(
    ThemeColors colors,
    AttendanceCorrectionModel data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daftar Persetujuan', style: AppTextStyles.h4(colors.textPrimary)),
        SizedBox(height: 12.h),
        ...data.approvers.map((approver) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              children: [
                UserAvatar(
                  avatarUrl: approver.approverProfile,
                  name: approver.userName,
                  size: 40,
                  fontSize: 14,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        approver.userName ?? '-',
                        style: AppTextStyles.bodyMedium(
                          colors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        approver.jobGradeName ?? '-',
                        style: AppTextStyles.caption(colors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          approver.statusAttendanceCorrection,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          color: _getStatusColor(
                            approver.statusAttendanceCorrection,
                          ).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusLabel(approver.statusAttendanceCorrection),
                        style:
                            AppTextStyles.caption(
                              _getStatusColor(
                                approver.statusAttendanceCorrection,
                              ),
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                            ),
                      ),
                    ),
                    if (approver.displayApprovalDate.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        approver.displayApprovalDate,
                        style: AppTextStyles.caption(
                          colors.textSecondary,
                        ).copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─── Status Badge ─────────────────────────────────────────────
  Widget _buildStatusBadge(ThemeColors colors, String status) {
    final statusUpper = status.toUpperCase();

    Color backgroundColor;
    Color textColor;

    if (statusUpper == 'UNVERIFIED') {
      backgroundColor = const Color(0xFFFFF3CD);
      textColor = const Color(0xFFD68910);
    } else if (statusUpper == 'APPROVED' || statusUpper.contains('APPROVE')) {
      backgroundColor = const Color(0xFFD4EDDA);
      textColor = const Color(0xFF28A745);
    } else if (statusUpper == 'REJECTED' || statusUpper.contains('REJECT')) {
      backgroundColor = const Color(0xFFF8D7DA);
      textColor = const Color(0xFFDC3545);
    } else if (statusUpper == 'PENDING' || statusUpper.contains('WAITING')) {
      backgroundColor = const Color(0xFFFFF3CD);
      textColor = const Color(0xFFD68910);
    } else {
      backgroundColor = colors.divider;
      textColor = colors.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        status,
        style: AppTextStyles.caption(
          textColor,
        ).copyWith(fontWeight: FontWeight.w600, fontSize: 11.sp),
      ),
    );
  }

  // ─── Bottom Action Button ─────────────────────────────────────
  Widget _buildBottomButton(ThemeColors colors) {
    // UNVERIFIED → "Batalkan" (red filled)
    if (_data!.isUnverified) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: () => _showCancelConfirmation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.red500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Batalkan',
                style: AppTextStyles.bodySemiBold(Colors.white),
              ),
            ),
          ),
        ),
      );
    }

    // APPROVED → "Tutup Permintaan" (outline style)
    if (_data!.isApproved) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: SizedBox(
            width: double.infinity,
            height: 44.h,
            child: OutlinedButton(
              onPressed: () => _showCloseConfirmation(),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primaryBlue,
                side: BorderSide(color: colors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Tutup Permintaan',
                style: AppTextStyles.bodySemiBold(colors.primaryBlue),
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showCancelConfirmation() {
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        title: Text(
          'Batalkan Koreksi Kehadiran',
          style: AppTextStyles.h4(colors.textPrimary),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan permintaan koreksi kehadiran ini?',
          style: AppTextStyles.body(colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tidak',
              style: AppTextStyles.bodyMedium(colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelCorrection();
            },
            child: Text(
              'Ya',
              style: AppTextStyles.bodyMedium(ColorPalette.red500),
            ),
          ),
        ],
      ),
    );
  }

  void _showCloseConfirmation() {
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        title: Text(
          'Tutup Permintaan',
          style: AppTextStyles.h4(colors.textPrimary),
        ),
        content: Text(
          'Apakah Anda yakin ingin menutup permintaan koreksi kehadiran ini?',
          style: AppTextStyles.body(colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tidak',
              style: AppTextStyles.bodyMedium(colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelCorrection();
            },
            child: Text(
              'Ya',
              style: AppTextStyles.bodyMedium(colors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Formatting Helpers ───────────────────────────────────────

  /// Format date string to "12 Jan 2026" using FormatDate
  String _formatDetailDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return FormatDate.shortDateWithYear(date);
    } catch (e) {
      return dateStr;
    }
  }

  /// Format shift code: "P_13_21" → "Shift Flexible [ - ]"
  String _formatShiftCode(String? code) {
    if (code == null || code.isEmpty) return '- [ - ]';
    final formatted = code
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
    return 'Shift $formatted';
  }

  /// Format shift label for Kehadiran Aktual: "Shift Flexible [Sen, 24 Feb 2026]"
  String _formatShiftLabel(String? code, String? dateStr) {
    final shiftName = code != null
        ? code
              .replaceAll('_', ' ')
              .split(' ')
              .where((w) => w.isNotEmpty)
              .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
              .join(' ')
        : 'Flexible';
    final dateFormatted = dateStr != null ? _formatDetailDate(dateStr) : '-';
    return 'Shift $shiftName [$dateFormatted]';
  }

  /// Extract time from datetime string: "2026-02-24 14:00:00" → "14:00"
  String _formatTimeFromDatetime(String? datetimeStr) {
    if (datetimeStr == null || datetimeStr.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(datetimeStr);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  /// Extract time and short date: "2026-02-24 14:00:00" → "14:00 | 24 Feb"
  String _formatTimeDateFromDatetime(String? datetimeStr) {
    if (datetimeStr == null || datetimeStr.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(datetimeStr);
      final time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      final date = FormatDate.shortDateWithYear(dt);
      return '$time | $date';
    } catch (e) {
      return datetimeStr;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVE':
        return 'Mengetahui';
      case 'PENDING':
        return 'Menunggu';
      case 'REJECT':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVE':
        return ColorPalette.green600;
      case 'PENDING':
        return ColorPalette.orange500;
      case 'REJECT':
        return ColorPalette.red500;
      default:
        return ColorPalette.orange500;
    }
  }
}
