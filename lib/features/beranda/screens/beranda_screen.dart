import 'package:flutter/material.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/format_date.dart';
import 'package:hrd_app/features/beranda/widgets/beranda_app_bar.dart';
import 'package:hrd_app/features/beranda/widgets/user_profile_header.dart';
import 'package:hrd_app/features/beranda/widgets/attendance_card.dart';
import 'package:hrd_app/features/beranda/widgets/favorite_menu_section.dart';
import 'package:hrd_app/features/beranda/widgets/company_info_section.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';
import 'package:hrd_app/features/notification/screens/notification_screen.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final date = DateTime.now();

    // TODO: Replace with actual user data from API/state
    const String userName = 'SARUL PADILLAH';
    const String userPosition = 'CASHIER';

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const BerandaAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserProfileHeader(
              name: userName,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur Rekam Waktu belum tersedia'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              onLainnyaTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur Lainnya belum tersedia'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            // Menu Favorit Section
            FavoriteMenuSection(
              onItemTap: (FiturItemModel item) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fitur "${item.title}" belum tersedia'),
                    duration: const Duration(seconds: 1),
                  ),
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
