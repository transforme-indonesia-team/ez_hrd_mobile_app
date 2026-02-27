import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrd_app/features/fitur/cuti/screens/permintaan_cuti.dart';
import 'package:hrd_app/features/fitur/gaji/screens/slip_gaji_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hrd_app/core/constants/app_constants.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/core/utils/location_utils.dart';
import 'package:hrd_app/core/widgets/location_permission_dialog.dart';
import 'package:hrd_app/data/models/employee_shift_model.dart';
import 'package:hrd_app/data/services/attendance_service.dart';

import 'package:hrd_app/features/beranda/widgets/beranda_app_bar.dart';
import 'package:hrd_app/features/beranda/widgets/user_profile_header.dart';
import 'package:hrd_app/features/beranda/widgets/attendance_card.dart';
import 'package:hrd_app/features/beranda/widgets/favorite_menu_section.dart';
import 'package:hrd_app/features/beranda/widgets/company_info_section.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';
import 'package:hrd_app/features/notification/screens/notification_screen.dart';
import 'package:hrd_app/features/schedule/screens/schedule_screen.dart';
import 'package:hrd_app/features/beranda/widgets/riwayat_kehadiran_bottom_sheet.dart';
import 'package:hrd_app/features/rekam_waktu/screens/rekam_waktu_camera_screen.dart';
import 'package:hrd_app/features/rekam_waktu/screens/qr_scanner_screen.dart';
import 'package:hrd_app/features/fitur/lembur/screens/daftar_lembur_screen.dart';
import 'package:hrd_app/data/services/employee_service.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen>
    with WidgetsBindingObserver {
  bool _waitingForLocationSettings = false;
  bool _waitingForAppSettings = false;

  bool _isLoadingShift = true;
  EmployeeShiftModel? _shiftData;
  List<Map<String, dynamic>> _attendanceRecords = [];
  bool _isQrLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadShiftInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadShiftInfo() async {
    debugPrint('=== BERANDA: _loadShiftInfo() called ===');
    try {
      final today = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(today);

      final weekday = today.weekday;
      final startDate = DateTime(
        today.year,
        today.month,
        today.day - (weekday - 1),
      );
      final endDate = DateTime(today.year, today.month, today.day + 1);

      debugPrint('=== BERANDA: Fetching API... ===');
      final response = await AttendanceService().getAbsentEmployee(
        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;

      debugPrint('=== BERANDA: API response received ===');
      final original = response['original'] as Map<String, dynamic>?;

      if (original != null &&
          original['status'] == true &&
          original['records'] != null) {
        final recordsList = original['records'] as List;

        final List<Map<String, dynamic>> validRecords = [];
        for (final r in recordsList) {
          final record = r as Map<String, dynamic>;
          if (record['check_in'] != null && record['check_in'] != '-') {
            validRecords.add({
              ...record,
              'type': 'check_in',
              'time': record['check_in'],
              'photo': record['attendance_photo_in'],
            });
          }
          if (record['check_out'] != null && record['check_out'] != '-') {
            validRecords.add({
              ...record,
              'type': 'check_out',
              'time': record['check_out'],
              'photo': record['attendance_photo_out'],
            });
          }
        }

        final todayRecord = recordsList.firstWhere(
          (record) => record['date_schedule'] == todayStr,
          orElse: () => null,
        );

        debugPrint('=== BERANDA: Updating state with new data ===');
        setState(() {
          _attendanceRecords = validRecords;
          _shiftData = todayRecord != null
              ? EmployeeShiftModel.fromJson(todayRecord)
              : null;
          _isLoadingShift = false;
        });
      } else {
        setState(() {
          _shiftData = null;
          _isLoadingShift = false;
        });
      }
    } catch (e) {
      debugPrint('=== BERANDA: Error loading shift: $e ===');
      if (mounted) {
        setState(() => _isLoadingShift = false);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_waitingForLocationSettings || _waitingForAppSettings) {
        _waitingForLocationSettings = false;
        _waitingForAppSettings = false;
        Future.delayed(
          const Duration(milliseconds: AppConstants.lifecycleDelayMs),
          () {
            if (mounted) _onRekamWaktuTap();
          },
        );
      }
    }
  }

  Future<void> _onRekamWaktuTap() async {
    final result = await _checkGPSAndPermission();

    if (result && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RekamWaktuCameraScreen()),
      ).then((_) {
        // Refresh data setelah kembali dari rekam waktu
        debugPrint('=== BERANDA: Kembali dari rekam waktu, refreshing... ===');
        if (mounted) {
          setState(() => _isLoadingShift = true);
          _loadShiftInfo();
        }
      });
    }
  }

  Future<void> _onBarcodeTap() async {
    final result = await _checkGPSAndPermission();
    if (!result || !mounted) return;

    // Buka QR scanner
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );

    if (scannedCode == null || scannedCode.isEmpty || !mounted) return;

    // Loading state
    setState(() => _isQrLoading = true);

    try {
      final response = await EmployeeService().getDetail(
        employeeCode: scannedCode,
      );

      if (!mounted) return;

      final original = response['original'] as Map<String, dynamic>?;
      final records = original?['records'] as Map<String, dynamic>?;
      if (records == null) {
        setState(() => _isQrLoading = false);
        _showQrErrorDialog(original?['message'] ?? 'Karyawan tidak ditemukan');
        return;
      }

      final employeeName = records['employee_name'] as String?;
      final employeeCode = records['employee_code'] as String?;
      final profilePath = records['profile'] as String?;

      setState(() => _isQrLoading = false);

      // Navigate ke kamera rekam waktu dengan data karyawan dari scan
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RekamWaktuCameraScreen(
            scannedEmployeeCode: employeeCode ?? scannedCode,
            scannedEmployeeName: employeeName,
            scannedProfileUrl: profilePath,
          ),
        ),
      ).then((_) {
        if (mounted) {
          setState(() => _isLoadingShift = true);
          _loadShiftInfo();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isQrLoading = false);
        final errorMsg = e.toString();
        _showQrErrorDialog(errorMsg);
      }
    }
  }

  void _showQrErrorDialog(String message) {
    final colors = context.colors;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colors.background,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon with circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 48,
                  color: Colors.orange.shade400,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Gagal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OKE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _checkGPSAndPermission() async {
    bool serviceEnabled = await LocationUtils.isLocationServiceEnabled();
    if (!mounted) return false;

    if (!serviceEnabled) {
      LocationPermissionDialog.showGPSDialog(
        context: context,
        onOpenSettings: () {
          _waitingForLocationSettings = true;
          LocationUtils.openLocationSettings();
        },
      );
      return false;
    }

    var permission = await LocationUtils.checkPermission();
    if (!mounted) return false;

    if (permission == LocationPermission.denied) {
      permission = await LocationUtils.requestPermission();
      if (!mounted) return false;

      if (permission == LocationPermission.denied) {
        context.showErrorSnackbar('Izin lokasi ditolak');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      LocationPermissionDialog.showPermissionDialog(
        context: context,
        onOpenSettings: () {
          _waitingForAppSettings = true;
          LocationUtils.openAppSettings();
        },
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final date = DateTime.now();

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
              avatarUrl: userAvatar,
              date: FormatDate.todayWithDayName(date),
              shiftInfo: _shiftData?.displayShiftInfo ?? 'Shift tidak tersedia',
              isLoading: _isLoadingShift,
              jamMasuk: _shiftData?.formattedCheckIn,
              jamKeluar: _shiftData?.formattedCheckOut,
              photoIn: _shiftData?.formattedPhotoIn,
              photoOut: _shiftData?.formattedPhotoOut,
              onRekamWaktuTap: _onRekamWaktuTap,
              onBarcodeTap: _onBarcodeTap,
              isQrLoading: _isQrLoading,
              onLainnyaTap: () {
                RiwayatKehadiranBottomSheet.show(
                  context,
                  records: _attendanceRecords,
                );
              },
              onShiftTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScheduleScreen(),
                  ),
                );
              },
            ),
            FavoriteMenuSection(
              onItemTap: (FiturItemModel item) {
                switch (item.id) {
                  case 'permintaan_lembur':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DaftarLemburScreen(),
                      ),
                    );
                    break;
                  case 'permintaan_cuti':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PermintaanCutiScreen(),
                      ),
                    );
                  case 'slip_gaji_saya':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SlipGajiScreen(),
                      ),
                    );
                  default:
                    context.showInfoSnackbar(
                      'Fitur "${item.title}" belum tersedia',
                    );
                }
              },
            ),
            const CompanyInfoSection(),
          ],
        ),
      ),
    );
  }
}
