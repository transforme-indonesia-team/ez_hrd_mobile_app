import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/features/fitur/cuti/screens/jatah_cuti_screen.dart';
import 'package:hrd_app/features/fitur/kehadiran/screens/daftar_kehadiran_screen.dart';
import 'package:hrd_app/features/profile/widgets/qr_code_bottom_sheet.dart';
import 'package:hrd_app/features/profile/detail/ketenagakerjaan/ketenagakerjaan_screen.dart';
import 'package:hrd_app/features/fitur/permohonan/screens/permohonan_karyawan_screen.dart';
import 'package:provider/provider.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/features/profile/models/profile_detail_model.dart';
import 'package:hrd_app/features/profile/widgets/profile_header.dart';
import 'package:hrd_app/features/profile/widgets/profile_info_section.dart';
import 'package:hrd_app/features/profile/widgets/profile_menu_item.dart';
import 'package:hrd_app/features/profile/widgets/profile_empty_state.dart';
import 'package:hrd_app/features/profile/detail/pribadi/pribadi_screen.dart';
import 'package:hrd_app/data/services/employee_service.dart';

class ProfileDetailScreen extends StatefulWidget {
  /// Jika null → profil sendiri (dari AuthProvider)
  /// Jika diisi → fetch profil karyawan lain via getDetail API
  final String? employeeCode;

  const ProfileDetailScreen({super.key, this.employeeCode});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  ProfileDetailModel? _profile;
  List<ProfileMenuItemModel> _menuItems = [];
  bool _isLoading = true;
  String? _error;

  /// Apakah ini profil sendiri
  bool get _isSelfProfile => widget.employeeCode == null;

  @override
  void initState() {
    super.initState();
    _initMenuItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isSelfProfile) {
      final user = context.read<AuthProvider>().user;
      setState(() {
        _profile = ProfileDetailModel.fromUser(user);
        _isLoading = false;
      });
    } else if (_isLoading && _error == null) {
      _fetchEmployeeProfile();
    }
  }

  Future<void> _fetchEmployeeProfile() async {
    try {
      final response = await EmployeeService().getDetail(
        employeeCode: widget.employeeCode,
      );

      if (!mounted) return;

      final original = response['original'] as Map<String, dynamic>?;
      final records = original?['records'] as Map<String, dynamic>?;

      if (records != null) {
        setState(() {
          _profile = ProfileDetailModel.fromEmployeeDetail(records);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = original?['message'] ?? 'Data karyawan tidak ditemukan';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('ProfileDetail: Error fetching employee: $e');
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data karyawan';
          _isLoading = false;
        });
      }
    }
  }

  void _initMenuItems() {
    final pribadiSubItems = [
      'Informasi Dasar',
      'Alamat',
      'Kontak',
      'Kontak darurat',
      'Pendidikan',
      'Daftar Bank',
      'Data Asuransi',
      'Catatan Pelatihan',
    ];

    final ketenagakerjaanSubItems = [
      'Info Ketenagakerjaan',
      'Disiplin',
      'Penghargaan',
    ];

    _menuItems = [
      ProfileMenuItemModel(
        icon: Icons.person_outline,
        title: 'Pribadi',
        subItems: pribadiSubItems,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PribadiScreen(profile: _profile!, menuItems: pribadiSubItems),
            ),
          );
        },
      ),
      ProfileMenuItemModel(
        icon: Icons.work_outline,
        title: 'Data Ketenagakerjaan',
        subItems: ['Info Ketenagakerjaan', 'Disiplin', 'Penghargaan'],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KetenagakerjaanScreen(
                profile: _profile!,
                menuItems: ketenagakerjaanSubItems,
              ),
            ),
          );
        },
      ),
      ProfileMenuItemModel(
        icon: Icons.calendar_today_outlined,
        title: 'Daftar Kehadiran',
        subItems: ['Kehadiran Karyawan'],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DaftarKehadiranScreen(),
            ),
          );
        },
      ),
      ProfileMenuItemModel(
        icon: Icons.description_outlined,
        title: 'Permohonan Karyawan',
        subItems: [
          'Koreksi Kehadiran',
          'Cuti',
          'Lembur',
          'Permintaan Khusus Kehadiran',
          'Permohonan Karyawan',
        ],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PermohonanKaryawanScreen(),
          ),
        ),
      ),
      ProfileMenuItemModel(
        icon: Icons.beach_access_outlined,
        title: 'Jatah Cuti',
        subItems: ['Cuti Kehadiran Karyawan'],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JatahCutiScreen()),
        ),
      ),
    ];
  }

  void _onQRTap() {
    if (_profile == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QrCodeBottomSheet(
        employeeCode: _profile!.employeeCode ?? '-',
        name: _profile!.name,
        role: _profile!.role,
      ),
    );
  }

  void _onMoreMenuTap() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Bagikan Profil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onEditSocialMedia() {
    context.showFeatureNotAvailable('Edit media sosial');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.appBar,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil Karyawan',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error!,
                    style: AppTextStyles.body(colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  if (!_isSelfProfile)
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });
                        _fetchEmployeeProfile();
                      },
                      child: const Text('Coba Lagi'),
                    ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(
                    profile: _profile!,
                    onQRTap: _onQRTap,
                    onMenuTap: _isSelfProfile ? _onMoreMenuTap : null,
                  ),

                  ProfileInfoSection(
                    company: _profile!.company,
                    organizationName: _profile!.organizationName,
                    socialMediaLinks: _profile!.socialMediaLinks,
                    onEditSocialMedia: _isSelfProfile
                        ? _onEditSocialMedia
                        : null,
                  ),
                  SizedBox(height: 16.h),

                  Column(
                    children: _menuItems.map((item) {
                      return ProfileMenuItem(item: item);
                    }).toList(),
                  ),

                  const ProfileEmptyState(),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
    );
  }
}
