import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

/// Custom App Bar untuk Beranda
class BerandaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BerandaAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      titleSpacing: 16.w,
      title: Text('EZ Parking', style: AppTextStyles.h3(colors.textPrimary)),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Navigate to more options
          },
          icon: Icon(
            Icons.chevron_right,
            color: colors.textSecondary,
            size: 24.sp,
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO: Navigate to search
          },
          icon: Icon(Icons.search, color: colors.textSecondary, size: 24.sp),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}
