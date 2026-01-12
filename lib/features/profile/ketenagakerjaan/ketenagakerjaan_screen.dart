import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/core/utils/string_utils.dart';
import 'package:hrd_app/features/profile/ketenagakerjaan/disiplin_screen.dart';
import 'package:hrd_app/features/profile/ketenagakerjaan/info_ketenagakerjaan_screen.dart';
import 'package:hrd_app/features/profile/models/profile_detail_model.dart';
import 'package:hrd_app/features/profile/pribadi/alamat_screen.dart';
import 'package:hrd_app/features/profile/pribadi/daftar_bank_screen.dart';
import 'package:hrd_app/features/profile/pribadi/data_asuransi_screen.dart';
import 'package:hrd_app/features/profile/pribadi/informasi_dasar_screen.dart';
import 'package:hrd_app/features/profile/pribadi/keluarga_screen.dart';
import 'package:hrd_app/features/profile/pribadi/kontak_darurat_screen.dart';
import 'package:hrd_app/features/profile/pribadi/kontak_screen.dart';
import 'package:hrd_app/features/profile/pribadi/pelatihan_screen.dart';
import 'package:hrd_app/features/profile/pribadi/pendidikan_screen.dart';
import 'package:hrd_app/features/profile/pribadi/pengalaman_kerja_screen.dart';
import 'package:hrd_app/features/profile/pribadi/rekam_medis_screen.dart';

class KetenagakerjaanScreen extends StatelessWidget {
  final ProfileDetailModel profile;
  final List<String> menuItems;

  const KetenagakerjaanScreen({
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
        backgroundColor: colors.background,
        elevation: 0,
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
                  ? NetworkImage(profile.avatarUrl!)
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
          if (itemTitle.contains('Info Ketenagakerjaan')) {
            icon = Icons.person_2_outlined;
          } else if (itemTitle.contains('Disiplin')) {
            icon = Icons.assignment_outlined;
          } else if (itemTitle.contains('Penghargaan')) {
            icon = Icons.workspace_premium_sharp;
          } else if (itemTitle.contains('Kontrol Dokumen')) {
            icon = Icons.document_scanner_outlined;
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
              if (itemTitle.contains('Info Ketenagakerjaan')) {
                screen = const InfoKetenagakerjaanScreen();
              } else if (itemTitle.contains('Disiplin')) {
                screen = const DisiplinScreen();
              } else if (itemTitle.contains('Penghargaan')) {
                context.showMenuNotAvailable('Penghargaan');
                return;
              } else if (itemTitle.contains('Kontrol Dokumen')) {
                context.showMenuNotAvailable('Kontrol Dokumen');
                return;
              }

              if (screen != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screen!),
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
