import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/features/fitur/tugas/screens/buat_tugas_baru_screen.dart';
import 'package:hrd_app/features/fitur/tugas/widgets/tugas_filter_bottom_sheet.dart';

class TugasScreen extends StatefulWidget {
  const TugasScreen({super.key});

  @override
  State<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    super.dispose();
  }

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
        title: Text(
          'Tugas',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primaryBlue,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: colors.primaryBlue,
          indicatorWeight: 2,
          labelStyle: AppTextStyles.bodyMedium(colors.primaryBlue),
          unselectedLabelStyle: AppTextStyles.bodyMedium(colors.textSecondary),
          tabs: const [
            Tab(text: 'Diterima'),
            Tab(text: 'Dikirim'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(context, isDikirim: false),
          _buildTabContent(context, isDikirim: true),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BuatTugasBaruScreen(),
                  ),
                );
              },
              backgroundColor: colors.primaryBlue,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildTabContent(BuildContext context, {required bool isDikirim}) {
    final colors = context.colors;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Filter & Search bar area
          Container(
            color: colors.background,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) {
                        return TugasFilterBottomSheet(
                          onApply: (dateRange, status, prioritas) {
                            // TODO: Lakukan fetch data sesuai filter
                          },
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(Icons.filter_alt_outlined, color: colors.textSecondary, size: 24.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: colors.backgroundDetail, // Often search textfields have slight grey bg
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: colors.divider),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari',
                        hintStyle: AppTextStyles.small(colors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 11.h),
                        suffixIcon: Icon(Icons.search,
                            color: colors.textSecondary, size: 20.sp),
                      ),
                      style: AppTextStyles.small(colors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Empty State Area
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            color: colors.background,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80.sp,
                    color: colors.textSecondary.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Tidak ada data untuk ditampilkan',
                    style: AppTextStyles.body(colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          
          // Pagination Footer right below empty state container
          Container(
            color: colors.background,
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Column(
              children: [
                Divider(height: 1, color: colors.divider),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Showing 0 of 0 Data',
                      style: AppTextStyles.small(colors.textPrimary),
                    ),
                    SizedBox(width: 24.w),
                    Icon(Icons.chevron_left,
                        color: colors.textSecondary.withValues(alpha: 0.5), size: 20.sp),
                    SizedBox(width: 16.w),
                    Icon(Icons.chevron_right,
                        color: colors.textSecondary.withValues(alpha: 0.5), size: 20.sp),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
