import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/features/profile/widgets/daftar_karyawan_bottom_sheet.dart';

class AktivitasHarianScreen extends StatefulWidget {
  const AktivitasHarianScreen({super.key});

  @override
  State<AktivitasHarianScreen> createState() => _AktivitasHarianScreenState();
}

class _AktivitasHarianScreenState extends State<AktivitasHarianScreen> {
  bool _isListView = true; // true = List (timeline), false = Grid (empty state for now)

  void _showDaftarKaryawan() {
    DaftarKaryawanBottomSheet.show(context);
  }

  Widget _buildTopMembersBox(ThemeColors colors) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 60.w,
                child: Text('Saya', style: AppTextStyles.bodySemiBold(colors.textPrimary)),
              ),
              Expanded(
                child: Text('Rekan Setim', style: AppTextStyles.bodySemiBold(colors.textPrimary)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              // SAYA
              Container(
                width: 65.w,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: colors.primaryBlue.withAlpha(25),
                  border: Border.all(color: colors.primaryBlue),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: colors.divider,
                      child: Text('PT', style: AppTextStyles.bodySemiBold(colors.textSecondary).copyWith(fontSize: 14.sp)),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'PRIMA...',
                      style: AppTextStyles.smallMedium(colors.textPrimary).copyWith(fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              // REKAN SETIM 1
              Column(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: colors.divider,
                    child: Text('DT', style: AppTextStyles.bodySemiBold(colors.textSecondary).copyWith(fontSize: 14.sp)),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'DANY',
                    style: AppTextStyles.smallMedium(colors.textPrimary).copyWith(fontSize: 10.sp),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              // REKAN SETIM 2
              Column(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: colors.divider,
                    child: Text('ST', style: AppTextStyles.bodySemiBold(colors.textSecondary).copyWith(fontSize: 14.sp)),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'SYAHRUL',
                    style: AppTextStyles.smallMedium(colors.textPrimary).copyWith(fontSize: 10.sp),
                  ),
                ],
              ),
              const Spacer(),
              // Arrow Button
              InkWell(
                onTap: _showDaftarKaryawan,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.divider),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Icon(Icons.chevron_right, color: colors.primaryBlue, size: 20.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip(ThemeColors colors) {
    final List<String> days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    final List<String> dates = ['29', '30', '31', '01', '02', '03', '04'];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Maret 2026', style: AppTextStyles.body(colors.textPrimary)),
              Row(
                children: [
                  Icon(Icons.chevron_left, color: colors.textSecondary, size: 20.sp),
                  SizedBox(width: 16.w),
                  Icon(Icons.chevron_right, color: colors.textSecondary, size: 20.sp),
                ],
              )
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final bool isSelected = index == 0;
              return Column(
                children: [
                  Text(
                    days[index],
                    style: AppTextStyles.small(colors.textSecondary).copyWith(fontSize: 11.sp),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primaryBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dates[index],
                      style: isSelected
                          ? AppTextStyles.bodySemiBold(Colors.white).copyWith(fontSize: 13.sp)
                          : AppTextStyles.bodySemiBold(colors.textSecondary).copyWith(fontSize: 13.sp, color: index > 2 ? colors.divider : colors.textPrimary),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ThemeColors colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.calendar_month_outlined, color: colors.primaryBlue, size: 18.sp),
            label: Text('Rekam Aktivitas', style: AppTextStyles.bodySemiBold(colors.primaryBlue).copyWith(fontSize: 13.sp)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.primaryBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => setState(() => _isListView = true),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: _isListView ? colors.primaryBlue.withAlpha(25) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.format_list_bulleted, color: _isListView ? colors.primaryBlue : colors.textSecondary, size: 20.sp),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _isListView = false),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: !_isListView ? colors.primaryBlue.withAlpha(25) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.grid_view, color: !_isListView ? colors.primaryBlue : colors.textSecondary, size: 20.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeColors colors) {
    return Container(
      padding: EdgeInsets.only(top: 40.h),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.event_busy, color: colors.divider, size: 80.sp),
          SizedBox(height: 16.h),
          Text(
            'Anda tidak memiliki aktivitas apa pun',
            style: AppTextStyles.bodySemiBold(colors.textPrimary).copyWith(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(ThemeColors colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: List.generate(10, (index) {
          final hour = index.toString().padLeft(2, '0');
          return Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('$hour:00', style: AppTextStyles.body(colors.textPrimary)),
                SizedBox(width: 16.w),
                Expanded(
                  child: Container(
                    height: 1,
                    color: colors.divider,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
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
          'Aktivitas Harian',
          style: AppTextStyles.h4(colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sync, color: colors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopMembersBox(colors),
            _buildCalendarStrip(colors),
            _buildFilterBar(colors),
            Divider(color: colors.divider, height: 1),
            _isListView ? _buildTimelineList(colors) : _buildEmptyState(colors),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: colors.primaryBlue,
        child: Icon(Icons.add, color: Colors.white, size: 28.sp),
      ),
    );
  }
}
