import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/utils/image_url_extension.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';
import 'package:hrd_app/data/models/overtime_employee_model.dart';
import 'package:hrd_app/data/services/overtime_service.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/detail_lembur_widgets.dart';

class DetailLemburScreen extends StatefulWidget {
  final OvertimeEmployeeModel? detailOvertime;

  const DetailLemburScreen({super.key, this.detailOvertime});

  @override
  State<DetailLemburScreen> createState() => _DetailLemburScreenState();
}

class _DetailLemburScreenState extends State<DetailLemburScreen> {
  bool _isKehadiranExpanded = false;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  OvertimeDetailResponse? _detailResponse;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await OvertimeService().getDetailOvertime(
        overtimeId: widget.detailOvertime!.id,
      );
      final records = response['original'];

      // Check if records is valid Map with 'records' key
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
          _detailResponse = OvertimeDetailResponse.fromJson(records);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching detail lembur: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Terjadi kesalahan saat memuat data';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelOvertime() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await OvertimeService().cancellationOVertime(
        overtimeId: widget.detailOvertime!.id,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      final records = response['original'];
      final isSuccess = records['status'] == true || records['code'] == 200;

      if (isSuccess) {
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(records['message'] ?? 'Lembur berhasil dibatalkan'),
              backgroundColor: ColorPalette.green600,
            ),
          );
          // Navigate back to list
          Navigator.pop(context, true); // true = refresh list
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(records['message'] ?? 'Gagal membatalkan lembur'),
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

  int _calculateDuration(String? start, String? end) {
    if (start == null || end == null) return 0;
    try {
      final startTime = TimeOfDay(
        hour: int.parse(start.split(':')[0]),
        minute: int.parse(start.split(':')[1]),
      );
      final endTime = TimeOfDay(
        hour: int.parse(end.split(':')[0]),
        minute: int.parse(end.split(':')[1]),
      );

      int startMinutes = startTime.hour * 60 + startTime.minute;
      int endMinutes = endTime.hour * 60 + endTime.minute;

      return endMinutes - startMinutes;
    } catch (e) {
      return 0;
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return 'Durasi yang diminta adalah $hours jam $mins menit';
    } else if (hours > 0) {
      return 'Durasi yang diminta adalah $hours jam';
    } else {
      return 'Durasi yang diminta adalah $mins menit';
    }
  }

  /// Build foto kehadiran dengan pattern dari beranda
  Widget _buildAttendancePhoto({
    required ThemeColors colors,
    required String? photoUrl,
    required String? name,
    required bool isCheckIn,
  }) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isCheckIn ? ColorPalette.green500 : ColorPalette.red500,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            photoUrl.asFullImageUrl ?? photoUrl,
            width: 40.w,
            height: 40.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return UserAvatar(name: name, size: 40, fontSize: 14);
            },
          ),
        ),
      );
    }
    return UserAvatar(name: name, size: 40, fontSize: 14);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rincian Riwayat Lembur',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: _buildContent(colors),
      bottomNavigationBar: _isLoading || _hasError || _detailResponse == null
          ? null
          : _buildCancelButton(colors, _detailResponse!.data),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    if (_isLoading) {
      return _buildSkeletonBody(colors);
    }

    if (_hasError || _detailResponse == null) {
      return EmptyStateWidget(
        message: _errorMessage ?? 'Data tidak tersedia',
        icon: Icons.error_outline,
      );
    }

    return _buildBody(colors);
  }

  Widget _buildSkeletonBody(ThemeColors colors) {
    return SkeletonContainer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LabelValueColumnSkeleton(valueWidth: 160),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: UserInfoItemSkeleton()),
                SizedBox(width: 12.w),
                const Expanded(child: UserInfoItemSkeleton()),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: LabelValueColumnSkeleton(valueWidth: 100),
                ),
                SizedBox(width: 12.w),
                const Expanded(
                  child: LabelValueColumnSkeleton(valueWidth: 100),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: LabelValueColumnSkeleton(valueWidth: 80)),
                SizedBox(width: 12.w),
                const Expanded(child: LabelValueColumnSkeleton(valueWidth: 40)),
              ],
            ),
            SizedBox(height: 16.h),
            const LabelValueColumnSkeleton(valueWidth: 60),
            SizedBox(height: 20.h),
            const DetailSectionSkeleton(),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: colors.divider.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: colors.textSecondary),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: 120.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 12.h),
            const ApprovalListItemSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeColors colors) {
    if (_detailResponse == null) {
      return const Center(child: Text('Data tidak tersedia'));
    }

    final data = _detailResponse!.data;
    final detail = _detailResponse!.detail;
    final duration = _calculateDuration(data.startOvertime, data.endOvertime);

    return SingleChildScrollView(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            color: colors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nomor Permintaan
                LabelValueColumn(
                  label: 'Nomor Permintaan',
                  value: data.displayOvertimeRequestNo,
                  fontSize: 15.sp,
                ),
                SizedBox(height: 16.h),

                // Permintaan untuk & Permintaan Oleh
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: UserInfoItem(
                        label: 'Permintaan untuk',
                        name: data.displayEmployeeName,
                        role: 'EMPLOYEE',
                        photoUrl: data.profile,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: UserInfoItem(
                        label: 'Permintaan Oleh',
                        name: data.createdBy ?? '-',
                        role: 'CREATOR',
                        photoUrl: data.createdByPhoto,
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
                        value: data.dateOvertime != null
                            ? FormatDate.fullDate(
                                DateTime.parse(data.dateOvertime!),
                              )
                            : '-',
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
                        value: data.dateOvertime != null
                            ? FormatDate.fullDate(
                                DateTime.parse(data.dateOvertime!),
                              )
                            : '-',
                        icon: Icon(
                          Icons.calendar_today_outlined,
                          size: 14.sp,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Tipe Permintaan & Alasan Lembur
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: LabelValueColumn(
                        label: 'Tipe Permintaan',
                        value: 'Jam Lembur',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: LabelValueColumn(
                        label: 'Keterangan',
                        value: data.remarkOvertime ?? '-',
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),

          // Detail Card Section
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: colors.backgroundDetail,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: colors.divider, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailSectionHeader(title: 'Detail Permintaan Lembur'),
                Divider(color: colors.divider, height: 1, thickness: 1),
                SizedBox(height: 14.h),
                // Tanggal
                Text(
                  data.dateOvertime != null
                      ? FormatDate.fullDate(DateTime.parse(data.dateOvertime!))
                      : '-',
                  style: AppTextStyles.bodyLarge(
                    colors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w700, fontSize: 14.sp),
                ),
                SizedBox(height: 4.h),
                // Shift
                Text(
                  detail.displayShiftTime,
                  style: AppTextStyles.body(
                    colors.textPrimary,
                  ).copyWith(fontSize: 13.sp),
                ),
                SizedBox(height: 14.h),
                // Waktu Aktual
                Text(
                  'Waktu Aktual',
                  style: AppTextStyles.bodyMedium(
                    colors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: DetailCardItem(
                        label: 'Jam Masuk',
                        value: detail.displayCheckIn,
                        isBoldValue: true,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: DetailCardItem(
                        label: 'Jam Keluar',
                        value: detail.displayCheckOut,
                        isBoldValue: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                // Lembur 1
                Text(
                  'Lembur 1',
                  style: AppTextStyles.bodyMedium(
                    colors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: DetailCardItem(
                        label: 'Mulai Lembur',
                        value:
                            '${data.startOvertime ?? '--:--'} | ${data.dateOvertime != null ? FormatDate.shortDateWithYear(DateTime.parse(data.dateOvertime!)) : '-'}',
                        isBoldValue: true,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: DetailCardItem(
                        label: 'Lembur Berakhir',
                        value:
                            '${data.endOvertime ?? '--:--'} | ${data.dateOvertime != null ? FormatDate.shortDateWithYear(DateTime.parse(data.dateOvertime!)) : '-'}',
                        isBoldValue: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Durasi
                Text(
                  _formatDuration(duration),
                  style: AppTextStyles.caption(
                    colors.textSecondary,
                  ).copyWith(fontSize: 11.sp),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Kehadiran Aktual - Expandable Card
          _buildKehadiranAktualCard(colors, data, detail),

          SizedBox(height: 24.h),

          // Daftar Persetujuan Section
          _buildApprovalSection(colors),
        ],
      ),
    );
  }

  Widget _buildKehadiranAktualCard(
    ThemeColors colors,
    OvertimeEmployeeModel data,
    OvertimeDetailModel detail,
  ) {
    return Container(
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
                _isKehadiranExpanded = !_isKehadiranExpanded;
              });
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kehadiran Aktual',
                    style: AppTextStyles.bodyMedium(colors.textSecondary),
                  ),
                  Icon(
                    _isKehadiranExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_isKehadiranExpanded) ...[
            Divider(color: colors.divider, height: 1),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.dateOvertime != null
                        ? FormatDate.fullDate(
                            DateTime.parse(data.dateOvertime!),
                          )
                        : '-',
                    style: AppTextStyles.bodyMedium(
                      colors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Shift: ${detail.displayShiftTime}',
                    style: AppTextStyles.caption(colors.textSecondary),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: AttendanceTimeCard(
                          label: 'Jam Masuk',
                          time: detail.displayCheckIn,
                          hasError: detail.hasCheckInError,
                          avatar: _buildAttendancePhoto(
                            colors: colors,
                            photoUrl: detail.attendancePhotoIn,
                            name: data.employeeName,
                            isCheckIn: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AttendanceTimeCard(
                          label: 'Jam Keluar',
                          time: detail.displayCheckOut,
                          hasError: detail.hasCheckOutError,
                          avatar: _buildAttendancePhoto(
                            colors: colors,
                            photoUrl: detail.attendancePhotoOut,
                            name: data.employeeName,
                            isCheckIn: false,
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

  Widget _buildApprovalSection(ThemeColors colors) {
    // Langsung ambil dari _detailResponse
    final approverList = _detailResponse?.approverRequest ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Daftar Persetujuan", style: AppTextStyles.h4(colors.textPrimary)),
        SizedBox(height: 12.h),
        if (approverList.isEmpty)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: colors.divider.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'Belum ada persetujuan',
                style: AppTextStyles.caption(colors.textSecondary),
              ),
            ),
          )
        else
          ...approverList.map((approver) {
            return ApprovalListItem(
              name: approver.displayApproverName,
              role: approver.approverPosisition ?? '-',
              status: _getStatusLabel(approver.statusApproval),
              statusColor: _getStatusColor(approver.statusApproval),
              photoUrl: approver.approverProfile,
            );
          }),
      ],
    );
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

  /// Check if can cancel - only if status is DRAFT or PENDING
  bool _canCancel(OvertimeEmployeeModel data) {
    final status = data.status?.toUpperCase();
    return status == 'DRAFT' || status == 'PENDING';
  }

  Widget _buildCancelButton(ThemeColors colors, OvertimeEmployeeModel data) {
    if (!_canCancel(data)) return const SizedBox.shrink();

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: SizedBox(
          width: double.infinity,
          height: 40.h,
          child: ElevatedButton(
            onPressed: () {
              _showCancelConfirmation(context);
            },
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

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Lembur'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan permintaan lembur ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              _cancelOvertime();
              Navigator.pop(context);
            },
            child: Text('Ya', style: TextStyle(color: ColorPalette.red500)),
          ),
        ],
      ),
    );
  }
}
