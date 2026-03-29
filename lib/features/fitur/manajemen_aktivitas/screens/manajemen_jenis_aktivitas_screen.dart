import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/features/fitur/manajemen_aktivitas/screens/buat_jenis_aktivitas_screen.dart';

class ManajemenJenisAktivitasScreen extends StatefulWidget {
  const ManajemenJenisAktivitasScreen({super.key});

  @override
  State<ManajemenJenisAktivitasScreen> createState() => _ManajemenJenisAktivitasScreenState();
}

class _ManajemenJenisAktivitasScreenState extends State<ManajemenJenisAktivitasScreen> {
  List<dynamic> _aktivitasList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  Future<void> _loadDummyData() async {
    try {
      final String response = await rootBundle.loadString('lib/data/dummy/manajemen_jenis_aktivitas_dummy.json');
      final data = json.decode(response);
      setState(() {
        _aktivitasList = data['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading dummy aktivitas data: $e');
    }
  }

  void _showOptionMenu(BuildContext context, ThemeColors colors, dynamic item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.only(top: 12.h, bottom: MediaQuery.of(context).padding.bottom + 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  // Action Ubah
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, color: colors.textSecondary, size: 22.sp),
                      SizedBox(width: 16.w),
                      Text(
                        'Ubah',
                        style: AppTextStyles.body(colors.textPrimary).copyWith(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  // Action Hapus
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: colors.textSecondary, size: 22.sp),
                      SizedBox(width: 16.w),
                      Text(
                        'Hapus',
                        style: AppTextStyles.body(colors.textPrimary).copyWith(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          'Manajemen Jenis Aktivitas',
          style: AppTextStyles.h4(colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: colors.textSecondary),
            onPressed: () {
              // Action Search
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: _aktivitasList.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final item = _aktivitasList[index];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: colors.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['activity_type_name'] ?? 'Aktivitas',
                              style: AppTextStyles.body(colors.textPrimary).copyWith(
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '-',
                              style: AppTextStyles.caption(colors.textSecondary).copyWith(
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => _showOptionMenu(context, colors, item),
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Icon(
                            Icons.more_vert,
                            color: colors.primaryBlue,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: colors.background,
            border: Border(top: BorderSide(color: colors.divider)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuatJenisAktivitasScreen()),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: Text(
                'Jenis Aktivitas Baru',
                style: AppTextStyles.button(Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryBlue,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
