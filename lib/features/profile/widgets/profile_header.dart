import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/image_url_extension.dart';
import 'package:hrd_app/core/utils/string_utils.dart';
import 'package:hrd_app/features/profile/models/profile_detail_model.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileDetailModel profile;
  final VoidCallback? onQRTap;
  final VoidCallback? onBaganTap;
  final VoidCallback? onMenuTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.onQRTap,
    this.onBaganTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.appBar,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.divider, width: 1),
      ),
      child: Row(
        children: [
          _buildAvatar(colors),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.toUpperCase(),
                  style: AppTextStyles.bodySemiBold(colors.textPrimary),
                ),
                SizedBox(height: 4.h),
                Text(
                  profile.role,
                  style: AppTextStyles.captionMedium(colors.textSecondary),
                ),
                SizedBox(height: 2.h),
                Text(
                  profile.employeeCode ?? '-',
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
              ],
            ),
          ),
          // Bagan icon
          if (onBaganTap != null)
            _buildActionIcon(
              icon: Icons.account_tree_outlined,
              onTap: onBaganTap!,
              colors: colors,
            ),
          // 3-dot popup menu
          _buildPopupMenu(colors),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: colors.divider, width: 1),
        ),
        child: Icon(icon, color: colors.primaryBlue, size: 20.sp),
      ),
    );
  }

  Widget _buildPopupMenu(ThemeColors colors) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'qr' && onQRTap != null) {
          onQRTap!();
        } else if (value == 'bagan' && onBaganTap != null) {
          onBaganTap!();
        }
      },
      offset: Offset(0, 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'qr',
          child: Text('Kode QR', style: AppTextStyles.body(colors.textPrimary)),
        ),
        PopupMenuItem(
          value: 'bagan',
          child: Text('Bagan', style: AppTextStyles.body(colors.textPrimary)),
        ),
      ],
      child: Container(
        width: 36.w,
        height: 36.w,
        margin: EdgeInsets.only(left: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: colors.divider, width: 1),
        ),
        child: Icon(Icons.more_vert, color: colors.primaryBlue, size: 20.sp),
      ),
    );
  }

  Widget _buildAvatar(ThemeColors colors) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: colors.divider, width: 2),
      ),
      child: profile.avatarUrl != null
          ? ClipOval(
              child: Image.network(
                profile.avatarUrl!.asFullImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitials(colors),
              ),
            )
          : _buildInitials(colors),
    );
  }

  Widget _buildInitials(ThemeColors colors) {
    return Center(
      child: Text(
        StringUtils.getInitials(profile.name),
        style: AppTextStyles.h2(colors.textSecondary),
      ),
    );
  }
}
