import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/features/fitur/company/screens/profile_perusahaan.dart';
import 'package:hrd_app/features/fitur/cuti/screens/kalender_cuti_screen.dart';
import 'package:hrd_app/features/fitur/cuti/screens/permintaan_cuti.dart';
import 'package:hrd_app/features/fitur/data/fitur_data.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_search_bar.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_section_header.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_category_header.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_item_grid.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_item_list.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/lembur/screens/daftar_lembur_screen.dart';
import 'package:hrd_app/features/profile/screens/profile_detail_screen.dart';

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
      default:
        context.showInfoSnackbar('Fitur "${item.title}" belum tersedia');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filteredSections = FiturData.search(_searchQuery);

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
            if (section.hasLainnya) ...[
              _buildSectionWithLainnya(section, colors),
            ] else ...[
              FiturSectionHeader(title: section.name),
              for (final category in section.categories) ...[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(color: colors.background),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FiturCategoryHeader(title: category.name),
                      if (_isGridView)
                        _buildGridItems(
                          category.items,
                          category.backgroundColor,
                          category.iconColor,
                        )
                      else
                        _buildListItems(
                          category.items,
                          category.backgroundColor,
                          category.iconColor,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionWithLainnya(
    FiturSectionModel section,
    ThemeColors colors,
  ) {
    final allItems = <FiturItemModel>[];
    Color? bgColor;
    Color? iconColor;

    for (final category in section.categories) {
      allItems.addAll(category.items);
      bgColor ??= category.backgroundColor;
      iconColor ??= category.iconColor;
    }

    final displayItems = allItems.take(4).toList();

    final lainnyaDisplayTitle = section.lainnyaTitle ?? section.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FiturSectionHeader(title: section.name),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.only(bottom: 12),
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
                      lainnyaDisplayTitle,
                      style: AppTextStyles.bodyMedium(colors.textPrimary),
                    ),
                    TextButton(
                      onPressed: () => _showLainnyaBottomSheet(section),
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
              const SizedBox(height: 8),
              if (_isGridView)
                _buildGridItems(displayItems, bgColor, iconColor)
              else
                _buildListItems(displayItems, bgColor, iconColor),
            ],
          ),
        ),
        for (final category in section.directCategories) ...[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: colors.background),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FiturCategoryHeader(title: category.name),
                const SizedBox(height: 16),
                if (_isGridView)
                  _buildGridItems(
                    category.items,
                    category.backgroundColor,
                    category.iconColor,
                  )
                else
                  _buildListItems(
                    category.items,
                    category.backgroundColor,
                    category.iconColor,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showLainnyaBottomSheet(FiturSectionModel section) {
    FiturBottomSheet.show(
      context,
      title: section.name.toUpperCase(),
      categories: section.categories,
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
          childAspectRatio: 0.85,
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
