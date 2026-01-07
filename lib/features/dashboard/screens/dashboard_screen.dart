import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/features/beranda/screens/beranda_screen.dart';
import 'package:hrd_app/features/fitur/screens/fitur_screen.dart';
import 'package:hrd_app/features/profile/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Daftar halaman untuk setiap tab
  List<Widget> get _pages => [
    const BerandaScreen(),
    const FiturScreen(),
    const _PostinganPage(),
    const _RuangKerjaPage(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: colors.background,
          selectedItemColor: colors.primaryBlue,
          unselectedItemColor: colors.inactiveGray,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Fitur',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: 'Postingan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              activeIcon: Icon(Icons.work),
              label: 'Ruang Kerja',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// HALAMAN-HALAMAN PLACEHOLDER
// ============================================

class _PostinganPage extends StatelessWidget {
  const _PostinganPage();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Postingan',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Halaman Postingan',
          style: TextStyle(color: colors.textPrimary),
        ),
      ),
    );
  }
}

class _RuangKerjaPage extends StatelessWidget {
  const _RuangKerjaPage();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Ruang Kerja',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Halaman Ruang Kerja',
          style: TextStyle(color: colors.textPrimary),
        ),
      ),
    );
  }
}
