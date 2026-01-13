import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/features/profile/pengaturan/ganti_password_screen.dart';

class PengaturanPersonalScreen extends StatelessWidget {
  const PengaturanPersonalScreen({super.key});

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
          'Pengaturan Personal',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card dengan Gradient
            _buildHeaderCard(context),
            SizedBox(height: 24.h),

            // Section: Akun & Keamanan
            _buildSectionTitle('AKUN & KEAMANAN', colors),
            SizedBox(height: 12.h),
            _buildMenuGrid(context, _akunKeamananItems),
            SizedBox(height: 8.h),
            Divider(color: colors.divider, thickness: 1),
            SizedBox(height: 16.h),

            // Section: Manajemen Fitur
            _buildSectionTitle('MANAJEMEN FITUR', colors),
            SizedBox(height: 12.h),
            _buildMenuGrid(context, _manajemenFiturItems),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF38BDF8), // sky-400
            Color(0xFF0EA5E9), // sky-500
            Color(0xFF0284C7), // sky-600
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.blue400.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalisasi Pengaturan Aplikasi Anda',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Kelola profil, keamanan, dan preferensi sesuai dengan kebutuhan Anda untuk pengalaman terbaik.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          // Quick action chips
          Row(
            children: [
              _buildQuickChip('Profil'),
              SizedBox(width: 8.w),
              _buildQuickChip('Keamanan'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: ColorPalette.blue600,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeColors colors) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: colors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, List<_MenuItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildMenuItem(context, items[index]);
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    final colors = context.colors;

    return InkWell(
      onTap: () {
        if (item.route != null) {
          switch (item.route) {
            case 'ganti_password':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GantiPasswordScreen(),
                ),
              );
              break;
            default:
              context.showMenuNotAvailable(item.label);
          }
        } else {
          context.showMenuNotAvailable(item.label);
        }
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: item.backgroundColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 22.sp),
          ),
          SizedBox(height: 6.h),
          Expanded(
            child: Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Data menu items
  List<_MenuItem> get _akunKeamananItems => [
    _MenuItem(
      icon: Icons.lock_outline,
      label: 'Ganti Kata Sandi',
      iconColor: ColorPalette.blue600,
      backgroundColor: ColorPalette.blue100,
      route: 'ganti_password',
    ),
    _MenuItem(
      icon: Icons.devices,
      label: 'Sesi Aktif',
      iconColor: ColorPalette.blue600,
      backgroundColor: ColorPalette.blue100,
    ),
    _MenuItem(
      icon: Icons.link,
      label: 'Akun Tertaut',
      iconColor: ColorPalette.blue600,
      backgroundColor: ColorPalette.blue100,
    ),
    _MenuItem(
      icon: Icons.security,
      label: 'Otentikator',
      iconColor: ColorPalette.blue600,
      backgroundColor: ColorPalette.blue100,
    ),
  ];

  List<_MenuItem> get _manajemenFiturItems => [
    _MenuItem(
      icon: Icons.notifications_outlined,
      label: 'Notifikasi',
      iconColor: ColorPalette.blue600,
      backgroundColor: ColorPalette.blue100,
    ),
    _MenuItem(
      icon: Icons.headset_mic_outlined,
      label: 'Memecahkan masalah',
      iconColor: ColorPalette.blue600,
      backgroundColor: ColorPalette.blue100,
    ),
  ];
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;
  final String? route;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
    this.route,
  });
}
