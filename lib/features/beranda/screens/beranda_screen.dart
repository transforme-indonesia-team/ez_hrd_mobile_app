import 'package:flutter/material.dart';
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

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

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
              onRekamWaktuTap: () {
                context.showInfoSnackbar('Fitur Rekam Waktu belum tersedia');
              },
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
