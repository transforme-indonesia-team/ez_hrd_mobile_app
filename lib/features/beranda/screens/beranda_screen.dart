import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/features/beranda/widgets/beranda_app_bar.dart';
import 'package:hrd_app/features/beranda/widgets/user_profile_header.dart';
import 'package:hrd_app/features/beranda/widgets/attendance_card.dart';
import 'package:hrd_app/features/beranda/widgets/favorite_menu_section.dart';
import 'package:hrd_app/features/beranda/widgets/company_info_section.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';
import 'package:hrd_app/features/notification/screens/notification_screen.dart';
import 'package:hrd_app/features/shift/screens/shift_screen.dart';
import 'package:hrd_app/features/beranda/widgets/riwayat_kehadiran_bottom_sheet.dart';
import 'package:hrd_app/core/utils/location_utils.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen>
    with WidgetsBindingObserver {
  bool _waitingForLocationSettings = false;
  bool _waitingForAppSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Ketika app kembali dari background (settings)
    if (state == AppLifecycleState.resumed) {
      if (_waitingForLocationSettings || _waitingForAppSettings) {
        _waitingForLocationSettings = false;
        _waitingForAppSettings = false;
        // Tunggu sebentar lalu retry
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _onRekamWaktuTap();
          }
        });
      }
    }
  }

  Future<void> _onRekamWaktuTap() async {
    final position = await LocationUtils.checkAndRequestLocation(
      onError: (message, type) {
        _handleLocationError(message, type);
      },
    );

    if (position != null && mounted) {
      // Lokasi berhasil didapat, lanjut ke fitur rekam waktu
      debugPrint('Latitude: ${position.latitude}');
      debugPrint('Longitude: ${position.longitude}');

      // TODO: Navigate ke screen rekam waktu atau proses attendance
      context.showSuccessSnackbar(
        'Lokasi berhasil! Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
      );
    }
  }

  void _handleLocationError(String message, LocationErrorType type) {
    if (!mounted) return;
    switch (type) {
      case LocationErrorType.serviceDisabled:
        _showGPSDialog();
        break;
      case LocationErrorType.permissionDeniedForever:
        _showPermissionDialog();
        break;
      default:
        context.showErrorSnackbar(message);
    }
  }

  void _showGPSDialog() {
    final colors = context.colors;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        contentPadding: EdgeInsets.all(24.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon GPS
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                color: colors.primaryBlue,
                size: 40.sp,
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              'Aktifkan Lokasi',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),

            // Message
            Text(
              'Untuk mencatat kehadiran, Anda perlu mengaktifkan layanan lokasi di perangkat.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: colors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Nanti Saja',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _waitingForLocationSettings = true;
                      LocationUtils.openLocationSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Aktifkan',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog() {
    final colors = context.colors;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        contentPadding: EdgeInsets.all(24.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Permission
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: colors.warning,
                size: 40.sp,
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              'Izin Lokasi Diperlukan',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),

            // Message
            Text(
              'Anda telah menolak izin lokasi. Silakan aktifkan izin lokasi di pengaturan aplikasi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: colors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Nanti Saja',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _waitingForAppSettings = true;
                      LocationUtils.openAppSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Buka Pengaturan',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final date = DateTime.now();

    // Get user data from AuthProvider
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final userName = user?.name ?? 'User';
    final userAvatar = user?.avatarUrl;
    final userPosition = user?.role ?? 'Employee';

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const BerandaAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserProfileHeader(
              name: userName,
              avatarUrl: userAvatar,
              position: userPosition,
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            AttendanceCard(
              name: userName,
              date: 'Hari ini ${FormatDate.todayWithDayName(date)}',
              shiftInfo: 'Shift: Shift Office Hour [09:00 - 17:00]',
              onRekamWaktuTap: _onRekamWaktuTap,
              onLainnyaTap: () {
                RiwayatKehadiranBottomSheet.show(context);
              },
              onShiftTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShiftScreen()),
                );
              },
            ),
            // Menu Favorit Section
            FavoriteMenuSection(
              onItemTap: (FiturItemModel item) {
                context.showInfoSnackbar(
                  'Fitur "${item.title}" belum tersedia',
                );
              },
            ),

            // Informasi Perusahaan Section
            const CompanyInfoSection(),
          ],
        ),
      ),
    );
  }
}
