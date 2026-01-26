import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
import 'package:hrd_app/features/fitur/lembur/screens/daftar_lembur_screen.dart';

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

      final response = await AttendanceService().getAbsentEmployee(
        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;

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

        setState(() {
          _attendanceRecords = validRecords;
          if (todayRecord != null) {
            _shiftData = EmployeeShiftModel.fromJson(todayRecord);
          }
          _isLoadingShift = false;
        });
      } else {
        setState(() => _isLoadingShift = false);
      }
    } catch (e) {
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
      );
    }
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
              date: 'Hari ini ${FormatDate.todayWithDayName(date)}',
              shiftInfo: _shiftData?.displayShiftInfo ?? 'Shift tidak tersedia',
              isLoading: _isLoadingShift,
              jamMasuk: _shiftData?.formattedCheckIn,
              jamKeluar: _shiftData?.formattedCheckOut,
              photoIn: _shiftData?.formattedPhotoIn,
              photoOut: _shiftData?.formattedPhotoOut,
              onRekamWaktuTap: _onRekamWaktuTap,
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
