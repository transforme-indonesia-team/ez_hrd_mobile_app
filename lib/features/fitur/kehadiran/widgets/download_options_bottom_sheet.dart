import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

enum DownloadOption {
  excel,
  email,
  viewDirectly,
  dailyAttendance,
}

class DownloadOptionsBottomSheet extends StatelessWidget {
  const DownloadOptionsBottomSheet({super.key});

  static Future<DownloadOption?> show(BuildContext context) {
    return showModalBottomSheet<DownloadOption>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const DownloadOptionsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(colors),
          _buildOptionItem(
            context,
            colors: colors,
            iconAsset: 'XLS',
            label: 'Unduh sebagai Excel',
            option: DownloadOption.excel,
          ),
          _buildOptionItem(
            context,
            colors: colors,
            icon: Icons.mail_outline,
            iconColor: colors.textSecondary.withValues(alpha: 0.8),
            label: 'Kirim ke Email',
            option: DownloadOption.email,
          ),
          _buildOptionItem(
            context,
            colors: colors,
            icon: Icons.open_in_new,
            iconColor: colors.textSecondary.withValues(alpha: 0.8),
            label: 'Lihat Langsung',
            option: DownloadOption.viewDirectly,
          ),
          _buildOptionItem(
            context,
            colors: colors,
            icon: Icons.open_in_new,
            iconColor: colors.textSecondary.withValues(alpha: 0.8),
            label: 'Kehadiran per Hari',
            option: DownloadOption.dailyAttendance,
            hideBorder: true,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
        ],
      ),
    );
  }

  Widget _buildDragHandle(ThemeColors colors) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 10.h, bottom: 4.h),
        width: 36.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: colors.divider,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required ThemeColors colors,
    IconData? icon,
    Color? iconColor,
    String? iconAsset,
    required String label,
    required DownloadOption option,
    bool hideBorder = false,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context, option),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: hideBorder
              ? null
              : Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: iconAsset == 'XLS'
                  ? Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D6F42), // Excel green
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'XLS',
                        style: AppTextStyles.buttonSmall(Colors.white)
                            .copyWith(fontSize: 8.sp, fontWeight: FontWeight.bold),
                      ),
                    )
                  : Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body(colors.textPrimary, fontSize: 13.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
