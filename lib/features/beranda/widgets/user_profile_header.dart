import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';

class UserProfileHeader extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String position;
  final String? avatarInitials;
  final VoidCallback? onNotificationTap;

  const UserProfileHeader({
    super.key,
    required this.name,
    this.avatarUrl,
    required this.position,
    this.avatarInitials,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: colors.background,
      child: Row(
        children: [
          UserAvatar(avatarUrl: avatarUrl, name: name, size: 48, fontSize: 16),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.h4(colors.textPrimary)),
                SizedBox(height: 2.h),
                Text(
                  position,
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNotificationTap ?? () {},
            icon: Icon(
              Icons.notifications,
              color: ColorPalette.slate500,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}
