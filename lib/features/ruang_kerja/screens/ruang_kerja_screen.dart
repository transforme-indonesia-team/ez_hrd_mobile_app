import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/features/ruang_kerja/widgets/survei_karyawan_tabs.dart';
import 'package:hrd_app/features/ruang_kerja/widgets/survei_empty_state.dart';
import 'package:hrd_app/features/ruang_kerja/widgets/rekan_setim_section.dart';
import 'package:hrd_app/features/ruang_kerja/widgets/tugasmu_section.dart';

/// Screen Ruang Kerja dengan Polling, Survei, Rekan Setim, dan Tugasmu
class RuangKerjaScreen extends StatefulWidget {
  const RuangKerjaScreen({super.key});

  @override
  State<RuangKerjaScreen> createState() => _RuangKerjaScreenState();
}

class _RuangKerjaScreenState extends State<RuangKerjaScreen> {
  int _selectedTabIndex = 0;

  // Dummy data untuk rekan setim
  final List<TeamMember> _teamMembers = const [
    TeamMember(name: 'SYAHRUL', initials: 'ST'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: _buildAppBar(colors),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Survei Karyawan Tabs
            SurveiKaryawanTabs(
              selectedIndex: _selectedTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),

            // Tab content - Empty state
            const SurveiEmptyState(),

            SizedBox(height: 8.h),

            // Rekan Setim Section
            RekanSetimSection(
              members: _teamMembers,
              onLainnyaTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur Lainnya belum tersedia'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              onMemberTap: (member) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Memberikan tugas ke ${member.name}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),

            SizedBox(height: 8.h),

            // Tugasmu Section
            TugasmuSection(
              onLainnyaTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur Lainnya belum tersedia'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(dynamic colors) {
    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      titleSpacing: 16.w,
      title: Text(
        'Ruang Kerja',
        style: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Implement search
          },
          icon: Icon(Icons.search, color: colors.textSecondary, size: 24.sp),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}
