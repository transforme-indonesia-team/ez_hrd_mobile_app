import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/color_palette.dart';

/// User profile header dengan avatar, nama, jabatan, dan notifikasi
class UserProfileHeader extends StatelessWidget {
  final String name;
  final String position;
  final String? avatarInitials;
  final VoidCallback? onNotificationTap;

  const UserProfileHeader({
    super.key,
    required this.name,
    required this.position,
    this.avatarInitials,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = avatarInitials ?? _getInitials(name);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: colors.background,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ColorPalette.orange400, width: 2),
            ),
            child: CircleAvatar(
              backgroundColor: colors.surface,
              child: Text(
                initials,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.orange500,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Name and position
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  position,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Notification icon
          IconButton(
            onPressed: onNotificationTap ?? () {},
            icon: Icon(
              Icons.notifications_outlined,
              color: colors.textSecondary,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 2).toUpperCase();
  }
}
