import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/features/beranda/screens/beranda_screen.dart';
import 'package:hrd_app/features/fitur/screens/fitur_screen.dart';
import 'package:hrd_app/features/postingan/screens/postingan_screen.dart';
import 'package:hrd_app/features/profile/screens/profile_screen.dart';
import 'package:hrd_app/features/ruang_kerja/screens/ruang_kerja_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    const BerandaScreen(),
    const FiturScreen(),
    const PostinganScreen(),
    const RuangKerjaScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: colors.background),
        child: SafeArea(
          top: false,
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
            selectedLabelStyle: AppTextStyles.xSmall(colors.primaryBlue),
            unselectedLabelStyle: AppTextStyles.xSmall(colors.inactiveGray),
            iconSize: 24.sp,
            selectedFontSize: 10.sp,
            unselectedFontSize: 10.sp,
            elevation: 0,
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
      ),
    );
  }
}
