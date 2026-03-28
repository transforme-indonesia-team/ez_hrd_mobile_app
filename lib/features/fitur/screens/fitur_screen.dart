import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/features/fitur/company/screens/profile_perusahaan.dart';
import 'package:hrd_app/features/fitur/cuti/screens/jatah_cuti_screen.dart';
import 'package:hrd_app/features/fitur/cuti/screens/kalender_cuti_screen.dart';
import 'package:hrd_app/features/fitur/cuti/screens/permintaan_cuti.dart';
import 'package:hrd_app/features/fitur/data/fitur_data.dart';
import 'package:hrd_app/features/fitur/gaji/screens/kata_sandi_slip_gaji_screen.dart';
import 'package:hrd_app/features/fitur/gaji/screens/slip_gaji_screen.dart';
import 'package:hrd_app/features/fitur/kehadiran/screens/laporan_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/kehadiran/screens/laporan_ringkasan_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/kehadiran/screens/laporan_lokasi_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/kehadiran/screens/laporan_kehadiran_yang_dicurigai_screen.dart';
import 'package:hrd_app/features/fitur/kehadiran/screens/laporan_kehadiran_wajah_yang_dicurigai_screen.dart';
import 'package:hrd_app/features/fitur/kehadiran/screens/laporan_koreksi_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/kehadiran/screens/laporan_log_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_search_bar.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_section_header.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_item_grid.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_item_list.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/lembur/screens/daftar_lembur_screen.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/screens/daftar_koreksi_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/permohonan/screens/permohonan_karyawan_screen.dart';
import 'package:hrd_app/features/fitur/jadwal_shift/screens/jadwal_shift_screen.dart';
import 'package:hrd_app/features/fitur/company/screens/struktur_organisasi_screen.dart';
import 'package:hrd_app/features/profile/screens/profile_detail_screen.dart';
import 'package:provider/provider.dart';

class FiturScreen extends StatefulWidget {
  const FiturScreen({super.key});

  @override
  State<FiturScreen> createState() => _FiturScreenState();
}

class _FiturScreenState extends State<FiturScreen> {
  bool _isGridView = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onItemTap(FiturItemModel item) {
    switch (item.id) {
      case 'permintaan_lembur':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DaftarLemburScreen()),
        );
        break;
      case 'permintaan_cuti':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PermintaanCutiScreen()),
        );
      case 'profile_perusahaan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfilePerusahaanScreen(),
          ),
        );
        break;
      case 'struktur_organisasi':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StrukturOrganisasiScreen(),
          ),
        );
        break;
      case 'data_personal':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileDetailScreen()),
        );
      case 'kalender_cuti':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KalenderCutiScreen()),
        );
      case 'jatah_cuti':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JatahCutiScreen()),
        );
      case 'slip_gaji_saya':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SlipGajiScreen()),
        );
      case 'kata_sandi_slip_gaji':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const KataSandiSlipGajiScreen(),
          ),
        );
      case 'daftar_kehadiran':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DaftarKoreksiKehadiranScreen(),
          ),
        );
        break;
      case 'permintaan_koreksi_kehadiran':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DaftarKoreksiKehadiranScreen(),
          ),
        );
        break;
      case 'permohonan_karyawan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PermohonanKaryawanScreen(),
          ),
        );
        break;
      case 'jadwal_shift':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JadwalShiftScreen()),
        );
        break;
      case 'laporan_kehadiran':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LaporanKehadiranScreen(),
          ),
        );
        break;
      case 'laporan_ringkasan_kehadiran':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LaporanRingkasanKehadiranScreen(),
          ),
        );
        break;
      case 'laporan_lokasi_kehadiran':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LaporanLokasiKehadiranScreen(),
          ),
        );
        break;
      case 'laporan_kehadiran_yang_dicurigai':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LaporanKehadiranYangDicurigaiScreen(),
          ),
        );
        break;
      case 'laporan_koreksi_kehadiran':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LaporanKoreksiKehadiranScreen(),
          ),
        );
        break;
      case 'laporan_kehadiran_wajah_yang_dicurigai':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LaporanKehadiranWajahYangDicurigaiScreen(),
          ),
        );
        break;
      case 'laporan_log_kehadiran':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LaporanLogKehadiranScreen(),
          ),
        );
        break;
      default:
        context.showInfoSnackbar('Fitur "${item.title}" belum tersedia');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final role = context.read<AuthProvider>().user?.role ?? '';
    // debugPrint("APAROLESAATINI $role");
    final filteredSections = FiturData.search(_searchQuery, role);

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            FiturSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
            _buildHeader(colors),

            Expanded(
              child: filteredSections.isEmpty
                  ? const EmptyStateWidget(
                      message: 'Fitur tidak ditemukan',
                      icon: Icons.search_off,
                    )
                  : _buildContent(filteredSections, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeColors colors) {
    return Container(
      color: colors.background,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Fitur', style: AppTextStyles.h4(colors.textPrimary)),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isGridView = false;
                    });
                  },
                  icon: Icon(
                    Icons.format_list_bulleted,
                    color: !_isGridView
                        ? colors.primaryBlue
                        : colors.inactiveGray,
                    size: 20.sp,
                  ),
                ),
                Container(height: 20.h, width: 1, color: colors.divider),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isGridView = true;
                    });
                  },
                  icon: Icon(
                    Icons.grid_view_rounded,
                    color: _isGridView
                        ? colors.primaryBlue
                        : colors.inactiveGray,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<FiturSectionModel> sections, ThemeColors colors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final section in sections) ...[
            FiturSectionHeader(title: section.name),
            for (final category in section.categories) ...[
              _buildCategory(category, colors),
            ],
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCategory(FiturCategoryModel category, ThemeColors colors) {
    final items = category.allItems;
    final hasLainnya = items.length > 4;
    final displayItems = hasLainnya ? items.take(4).toList() : items;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(color: colors.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: AppTextStyles.bodyMedium(colors.textPrimary),
                ),
                if (hasLainnya)
                  TextButton(
                    onPressed: () => _showLainnyaBottomSheet(category),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lainnya',
                          style: AppTextStyles.bodyMedium(colors.primaryBlue),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colors.primaryBlue,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_isGridView)
            _buildGridItems(
              displayItems,
              category.backgroundColor,
              category.iconColor,
            )
          else
            _buildListItems(
              displayItems,
              category.backgroundColor,
              category.iconColor,
            ),
        ],
      ),
    );
  }

  void _showLainnyaBottomSheet(FiturCategoryModel category) {
    FiturBottomSheet.show(
      context,
      title: category.name.toUpperCase(),
      category: category,
      onItemTap: _onItemTap,
    );
  }

  Widget _buildGridItems(
    List<FiturItemModel> items,
    Color? categoryBackgroundColor,
    Color? categoryIconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.72,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return FiturItemGrid(
            item: items[index],
            categoryBackgroundColor: categoryBackgroundColor,
            categoryIconColor: categoryIconColor,
            onTap: () => _onItemTap(items[index]),
          );
        },
      ),
    );
  }

  Widget _buildListItems(
    List<FiturItemModel> items,
    Color? categoryBackgroundColor,
    Color? categoryIconColor,
  ) {
    return Column(
      children: items.map((item) {
        return FiturItemList(
          item: item,
          categoryBackgroundColor: categoryBackgroundColor,
          categoryIconColor: categoryIconColor,
          onTap: () => _onItemTap(item),
        );
      }).toList(),
    );
  }
}
