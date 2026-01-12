import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/features/profile/ketenagakerjaan/ketenagakerjaan_screen.dart';
import 'package:provider/provider.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/features/profile/models/profile_detail_model.dart';
import 'package:hrd_app/features/profile/widgets/profile_header.dart';
import 'package:hrd_app/features/profile/widgets/profile_info_section.dart';
import 'package:hrd_app/features/profile/widgets/profile_menu_item.dart';
import 'package:hrd_app/features/profile/widgets/profile_empty_state.dart';
import 'package:hrd_app/features/profile/pribadi/pribadi_screen.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late ProfileDetailModel _profile;
  late final List<ProfileMenuItemModel> _menuItems;

  @override
  void initState() {
    super.initState();
    _initMenuItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get user data from AuthProvider and create profile
    final user = context.read<AuthProvider>().user;
    _profile = ProfileDetailModel.fromUser(user);
  }

  void _initMenuItems() {
    final pribadiSubItems = [
      'Informasi Dasar',
      'Alamat',
      'Kontak',
      'Kontak darurat',
      'Keluarga & Tanggungan',
      'Pendidikan',
      'Rekam Medis',
      'Pengalaman',
      'Daftar Bank',
      'Data Asuransi',
      'Catatan Pelatihan',
    ];

    final ketenagakerjaanSubItems = [
      'Info Ketenagakerjaan',
      'Disiplin',
      'Penghargaan',
      'Kontrol Dokumen',
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
                  PribadiScreen(profile: _profile, menuItems: pribadiSubItems),
            ),
          );
        },
      ),
      ProfileMenuItemModel(
        icon: Icons.work_outline,
        title: 'Data Ketenagakerjaan',
        subItems: [
          'Info Ketenagakerjaan',
          'Disiplin',
          'Penghargaan',
          'Kontrol Dokumen',
        ],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KetenagakerjaanScreen(
                profile: _profile,
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
        onTap: () => context.showMenuNotAvailable('Daftar Kehadiran'),
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
        onTap: () => context.showMenuNotAvailable('Permohonan Karyawan'),
      ),
      ProfileMenuItemModel(
        icon: Icons.beach_access_outlined,
        title: 'Jatah Cuti',
        subItems: ['Cuti Kehadiran Karyawan'],
        onTap: () => context.showMenuNotAvailable('Jatah Cuti'),
      ),
    ];
  }

  void _onQRTap() {
    context.showFeatureNotAvailable('QR Code');
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
                // TODO: Navigate to edit profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Bagikan Profil'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share profile
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
      backgroundColor: colors.backgroundDetail,
      appBar: AppBar(
        backgroundColor: colors.appBar,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil Karyawan',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              profile: _profile,
              onQRTap: _onQRTap,
              onMenuTap: _onMoreMenuTap,
            ),

            ProfileInfoSection(
              company: _profile.company,
              organizationName: _profile.organizationName,
              socialMediaLinks: _profile.socialMediaLinks,
              onEditSocialMedia: _onEditSocialMedia,
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
