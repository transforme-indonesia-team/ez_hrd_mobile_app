import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_search_bar.dart';
import 'package:hrd_app/features/fitur/saran/widgets/buat_saran_bottom_sheet.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';

class SaranScreen extends StatefulWidget {
  const SaranScreen({super.key});

  @override
  State<SaranScreen> createState() => _SaranScreenState();
}

class _SaranScreenState extends State<SaranScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showBuatSaranModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const BuatSaranBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saran',
          style: AppTextStyles.h4(colors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: colors.background,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: colors.primaryBlue,
                  unselectedLabelColor: colors.textSecondary,
                  indicatorColor: colors.primaryBlue,
                  labelStyle: AppTextStyles.bodyMedium(colors.primaryBlue)
                      .copyWith(fontWeight: FontWeight.w600),
                  unselectedLabelStyle: AppTextStyles.body(colors.textSecondary),
                  tabs: const [
                    Tab(text: 'Diterima'),
                    Tab(text: 'Dikirim'),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Show Filter
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(Icons.filter_alt_outlined, color: colors.textSecondary, size: 24.sp),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () {
                          // Show download options
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(Icons.file_download_outlined, color: colors.textSecondary, size: 24.sp),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: FiturSearchBar(
                          controller: _searchController,
                          onChanged: (val) {},
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Diterima
                _buildEmptyState(colors),
                // Tab Dikirim
                _buildEmptyState(colors),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: _showBuatSaranModal,
              backgroundColor: colors.primaryBlue,
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState(ThemeColors colors) {
    return Center(
      child: EmptyStateWidget(
        message: 'Tidak ada data',
        icon: Icons.star_border_rounded,
      ),
    );
  }
}
