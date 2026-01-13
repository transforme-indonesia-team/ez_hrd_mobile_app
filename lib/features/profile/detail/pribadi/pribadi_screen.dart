import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/config/env_config.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/string_utils.dart';
import 'package:hrd_app/features/profile/models/profile_detail_model.dart';
import 'package:hrd_app/features/profile/detail/pribadi/alamat_screen.dart';
import 'package:hrd_app/features/profile/detail/pribadi/daftar_bank_screen.dart';
import 'package:hrd_app/features/profile/detail/pribadi/data_asuransi_screen.dart';
import 'package:hrd_app/features/profile/detail/pribadi/informasi_dasar_screen.dart';
import 'package:hrd_app/features/profile/detail/pribadi/keluarga_screen.dart';
import 'package:hrd_app/features/profile/detail/pribadi/kontak_darurat_screen.dart';
import 'package:hrd_app/features/profile/detail/pribadi/kontak_screen.dart';
import 'package:hrd_app/features/profile/detail/pribadi/pelatihan_screen.dart';
import 'package:hrd_app/features/profile/detail/pribadi/pendidikan_screen.dart';
import 'package:hrd_app/features/profile/detail/pribadi/pengalaman_kerja_screen.dart';
import 'package:hrd_app/features/profile/detail/pribadi/rekam_medis_screen.dart';

class PribadiScreen extends StatelessWidget {
  final ProfileDetailModel profile;
  final List<String> menuItems;

  const PribadiScreen({
    super.key,
    required this.profile,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        // backgroundColor: colors.background,
        elevation: 5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: colors.divider,
              backgroundImage: profile.avatarUrl != null
                  ? NetworkImage(
                      '${EnvConfig.imageBaseUrl}${profile.avatarUrl!}',
                    )
                  : null,
              child: profile.avatarUrl == null
                  ? Text(
                      StringUtils.getInitials(profile.name),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                profile.name,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: menuItems.length,
        separatorBuilder: (context, index) => Divider(
          color: colors.divider,
          height: 1,
          thickness: 1,
          indent: 16.w,
        ),
        itemBuilder: (context, index) {
          final itemTitle = menuItems[index];

          IconData icon = Icons.circle_outlined;
          if (itemTitle.contains('Informasi')) {
            icon = Icons.person_outline;
          } else if (itemTitle.contains('Alamat')) {
            icon = Icons.location_on_outlined;
          } else if (itemTitle.contains('Kontak')) {
            icon = Icons.contact_page_outlined;
          } else if (itemTitle.contains('Keluarga')) {
            icon = Icons.family_restroom_outlined;
          } else if (itemTitle.contains('Pendidikan')) {
            icon = Icons.school_outlined;
          } else if (itemTitle.contains('Medis')) {
            icon = Icons.medical_services_outlined;
          } else if (itemTitle.contains('Pengalaman')) {
            icon = Icons.work_history_outlined;
          } else if (itemTitle.contains('Bank')) {
            icon = Icons.account_balance_outlined;
          } else if (itemTitle.contains('Asuransi')) {
            icon = Icons.health_and_safety_outlined;
          } else if (itemTitle.contains('Pelatihan')) {
            icon = Icons.assignment_outlined;
          }

          return ListTile(
            leading: Icon(icon, color: colors.textSecondary, size: 24.sp),
            title: Text(
              itemTitle,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: colors.textPrimary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colors.textSecondary.withValues(alpha: 0.5),
              size: 20.sp,
            ),
            onTap: () {
              Widget? screen;
              if (itemTitle.contains('Informasi Dasar')) {
                screen = const InformasiDasarScreen();
              } else if (itemTitle.contains('Alamat')) {
                screen = const AlamatScreen();
              } else if (itemTitle.contains('Kontak darurat')) {
                screen = const KontakDaruratScreen();
              } else if (itemTitle.contains('Kontak')) {
                screen = const KontakScreen();
              } else if (itemTitle.contains('Keluarga')) {
                screen = const KeluargaScreen();
              } else if (itemTitle.contains('Pendidikan')) {
                screen = const PendidikanScreen();
              } else if (itemTitle.contains('Rekam Medis')) {
                screen = const RekamMedisScreen();
              } else if (itemTitle.contains('Pengalaman')) {
                screen = const PengalamanKerjaScreen();
              } else if (itemTitle.contains('Bank')) {
                screen = const DaftarBankScreen();
              } else if (itemTitle.contains('Asuransi')) {
                screen = const DataAsuransiScreen();
              } else if (itemTitle.contains('Pelatihan')) {
                screen = const PelatihanScreen();
              }

              if (screen != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screen!),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Detail $itemTitle belum tersedia')),
                );
              }
            },
            contentPadding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 4.h,
            ),
          );
        },
      ),
    );
  }
}
