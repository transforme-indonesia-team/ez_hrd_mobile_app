import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/config/env_config.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';
import 'package:hrd_app/data/models/attendance_employee_model.dart';
import 'package:hrd_app/features/fitur/kehadiran/widgets/attendance_log_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/screens/form_koreksi_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/lembur/screens/form_lembur_screen.dart';
import 'package:hrd_app/features/fitur/cuti/screens/form_permintaan_cuti.dart';

class DetailKehadiranScreen extends StatefulWidget {
  final AttendanceEmployeeModel attendance;

  const DetailKehadiranScreen({super.key, required this.attendance});

  @override
  State<DetailKehadiranScreen> createState() => _DetailKehadiranScreenState();
}

class _DetailKehadiranScreenState extends State<DetailKehadiranScreen> {
  bool _showBasePhoto = false;

  AttendanceEmployeeModel get _att => widget.attendance;

  // --- Status helpers ---
  String get _statusLabel => _att.displayStatus;

  Color _statusBadgeColor(ThemeColors colors) {
    switch (_statusLabel) {
      case 'OK':
        return colors.success.withValues(alpha: 0.15);
      case 'IN':
        return colors.info.withValues(alpha: 0.15);
      default:
        return colors.primaryBlue.withValues(alpha: 0.15);
    }
  }

  Color _statusTextColor(ThemeColors colors) {
    switch (_statusLabel) {
      case 'OK':
        return colors.success;
      case 'IN':
        return colors.info;
      default:
        return colors.primaryBlue;
    }
  }

  String get _formattedDate {
    if (_att.dateSchedule == null) return '-';
    return FormatDate.fromString(_att.dateSchedule);
  }

  String get _shiftDisplay {
    final code = _att.shiftDailyCode ?? '';
    final time = _att.displayShift;
    if (code.isNotEmpty && time != code) {
      // e.g. "Shift Office Hour (09:00 - 17:00)"
      final label = code
          .replaceAll('_', ' ')
          .split(' ')
          .where((w) => w.isNotEmpty)
          .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
          .join(' ');
      return '$label ($time)';
    }
    return time;
  }

  bool get _isIncomplete => _att.isAbsent || !_att.hasCheckOut;

  String? _fullPhotoUrl(String? photo) {
    if (photo == null || photo.isEmpty || photo == '-') return null;
    return '${EnvConfig.imageBaseUrl}$photo';
  }

  String? get _profilePhotoUrl => _fullPhotoUrl(_att.profile);

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Kehadiran',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmployeeHeader(colors),
            Divider(height: 1, color: colors.divider),
            _buildInfoSection(colors),
            if (_isIncomplete) _buildWarningBanner(colors),
            _buildAttendanceSection(colors),
            _buildBasePhotoToggle(colors),
            SizedBox(height: 16.h),
            _buildRequestSection(colors),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  // ─── Employee Header ───────────────────────────────────────
  Widget _buildEmployeeHeader(ThemeColors colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          UserAvatar(
            avatarUrl: _att.profile,
            name: _att.employeeName,
            size: 44,
            fontSize: 16,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _att.displayEmployeeName,
                  style: AppTextStyles.bodySemiBold(colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_att.positionName != null)
                  Text(
                    _att.positionName!,
                    style: AppTextStyles.caption(colors.textSecondary),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showLogBottomSheet,
            child: Text(
              'Lihat Log',
              style: AppTextStyles.bodyMedium(colors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Info Section ──────────────────────────────────────────
  Widget _buildInfoSection(ThemeColors colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoLabel(colors, 'Tanggal'),
          SizedBox(height: 4.h),
          Text(_formattedDate, style: AppTextStyles.body(colors.textPrimary)),
          SizedBox(height: 16.h),

          _buildInfoLabel(colors, 'Shift'),
          SizedBox(height: 4.h),
          Text(_shiftDisplay, style: AppTextStyles.body(colors.textPrimary)),
          SizedBox(height: 16.h),

          _buildInfoLabel(colors, 'Status'),
          SizedBox(height: 4.h),
          _buildStatusBadge(colors),
          SizedBox(height: 16.h),

          _buildInfoLabel(colors, 'Keterangan'),
          SizedBox(height: 4.h),
          Text(
            _att.remarkSchedule ?? '-',
            style: AppTextStyles.body(colors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLabel(ThemeColors colors, String label) {
    return Text(label, style: AppTextStyles.caption(colors.textSecondary));
  }

  Widget _buildStatusBadge(ThemeColors colors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _statusBadgeColor(colors),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        _statusLabel,
        style: AppTextStyles.captionMedium(_statusTextColor(colors)),
      ),
    );
  }

  // ─── Warning Banner ────────────────────────────────────────
  Widget _buildWarningBanner(ThemeColors colors) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: colors.primaryBlue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Kehadiran Anda belum lengkap',
                style: AppTextStyles.bodyMedium(colors.primaryBlue),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      final date = _att.dateSchedule != null
                          ? DateTime.tryParse(_att.dateSchedule!)
                          : null;
                      return FormKoreksiKehadiranScreen(
                        initialStartDate: date,
                        initialEndDate: date,
                        employeeProfile: _att.profile,
                        employeeName: _att.displayEmployeeName,
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                elevation: 0,
              ),
              child: Text(
                'Koreksi Kehadiran',
                style: AppTextStyles.buttonSmall(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Attendance Section ────────────────────────────────────
  Widget _buildAttendanceSection(ThemeColors colors) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance',
            style: AppTextStyles.bodySemiBold(colors.textPrimary),
          ),
          SizedBox(height: 16.h),
          _buildAttendanceEntry(
            colors: colors,
            label: 'Jam Masuk',
            time: _att.displayCheckIn,
            photo: _att.attendancePhotoIn,
            hasData: _att.hasCheckIn,
          ),
          SizedBox(height: 24.h),
          _buildAttendanceEntry(
            colors: colors,
            label: 'Jam Keluar',
            time: _att.displayCheckOut,
            photo: _att.attendancePhotoOut,
            hasData: _att.hasCheckOut,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceEntry({
    required ThemeColors colors,
    required String label,
    required String time,
    required String? photo,
    required bool hasData,
  }) {
    final photoUrl = _fullPhotoUrl(photo);

    // When base photo is shown: just photos side-by-side, no info
    if (_showBasePhoto) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildPhotoBox(colors, photoUrl)),
              SizedBox(width: 8.w),
              Expanded(child: _buildPhotoBox(colors, _profilePhotoUrl)),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Foto Absen',
                    style: AppTextStyles.xSmall(colors.textSecondary),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Center(
                  child: Text(
                    'Foto Dasar',
                    style: AppTextStyles.xSmall(colors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Normal mode: photo + info side-by-side
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPhotoBox(colors, photoUrl),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodyMedium(colors.textPrimary)),
              SizedBox(height: 4.h),
              Text(time, style: AppTextStyles.h2(colors.textPrimary)),
              SizedBox(height: 8.h),
              _buildFaceRecognitionStatus(colors, hasData: hasData),
              SizedBox(height: 4.h),
              _buildLocationStatus(colors, hasData: hasData),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoBox(ThemeColors colors, String? photoUrl) {
    return Container(
      width: 100.w,
      height: 120.h,
      decoration: BoxDecoration(
        color: ColorPalette.slate200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: photoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPhotoPlaceholder();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorPalette.slate400,
                      ),
                    ),
                  );
                },
              ),
            )
          : _buildPhotoPlaceholder(),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Center(
      child: Icon(Icons.person, color: ColorPalette.slate400, size: 40.sp),
    );
  }

  Widget _buildFaceRecognitionStatus(
    ThemeColors colors, {
    required bool hasData,
  }) {
    final success = hasData;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          success ? Icons.face_retouching_natural : Icons.face_retouching_off,
          size: 16.sp,
          color: success ? colors.success : colors.primaryBlue,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            success
                ? 'Identifikasi Wajah: Berhasil'
                : 'Identifikasi Wajah:\nGagal (Wajah Tidak Ditemukan)',
            style: AppTextStyles.xSmall(
              success ? colors.success : colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationStatus(ThemeColors colors, {required bool hasData}) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 16.sp,
          color: hasData ? colors.success : colors.primaryBlue,
        ),
        SizedBox(width: 6.w),
        Text(
          hasData ? 'Lokasi terdeteksi' : '-',
          style: AppTextStyles.xSmall(
            hasData ? colors.success : colors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ─── Base Photo Toggle ─────────────────────────────────────
  Widget _buildBasePhotoToggle(ThemeColors colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: OutlinedButton.icon(
        onPressed: () => setState(() => _showBasePhoto = !_showBasePhoto),
        icon: Icon(
          _showBasePhoto ? Icons.close : Icons.visibility_outlined,
          size: 18.sp,
          color: colors.primaryBlue,
        ),
        label: Text(
          _showBasePhoto ? 'Tutup Base Photo' : 'Tampilkan Base Photo',
          style: AppTextStyles.buttonSmall(colors.primaryBlue),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          minimumSize: Size(double.infinity, 0),
        ),
      ),
    );
  }

  // ─── Permohonan Karyawan Section ───────────────────────────
  Widget _buildRequestSection(ThemeColors colors) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Text(
              'Permohonan Karyawan',
              style: AppTextStyles.bodySemiBold(colors.textPrimary),
            ),
          ),
          Divider(height: 1, color: colors.divider),
          _buildRequestTile(
            colors,
            title: 'Attendance Correction',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormKoreksiKehadiranScreen(
                    initialStartDate: _att.dateSchedule != null
                        ? DateTime.tryParse(_att.dateSchedule!)
                        : null,
                    initialEndDate: _att.dateSchedule != null
                        ? DateTime.tryParse(_att.dateSchedule!)
                        : null,
                  ),
                ),
              );
            },
          ),
          Divider(height: 1, indent: 16.w, color: colors.divider),
          _buildRequestTile(
            colors,
            title: 'Overtime',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FormLemburScreen()),
              );
            },
          ),
          Divider(height: 1, indent: 16.w, color: colors.divider),
          _buildRequestTile(
            colors,
            title: 'Leave',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FormPermintaanCutiScreeen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTile(
    ThemeColors colors, {
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: AppTextStyles.body(colors.textPrimary)),
            ),
            Icon(Icons.chevron_right, color: colors.textSecondary, size: 22.sp),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Sheet ──────────────────────────────────────────
  void _showLogBottomSheet() {
    DateTime? date;
    if (_att.dateSchedule != null) {
      try {
        date = DateTime.parse(_att.dateSchedule!);
      } catch (_) {}
    }

    AttendanceLogBottomSheet.show(context, startDate: date, endDate: date);
  }
}
