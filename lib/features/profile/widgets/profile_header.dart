import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/features/profile/models/profile_detail_model.dart';

/// Header widget untuk profile detail
/// Menampilkan avatar, nama, role, employee ID, dan action buttons
class ProfileHeader extends StatelessWidget {
  final ProfileDetailModel profile;
  final VoidCallback? onQRTap;
  final VoidCallback? onMenuTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.onQRTap,
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
          // Avatar
          _buildAvatar(colors),
          SizedBox(width: 16.w),

          // Name, Role, Employee ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  profile.role,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  profile.employeeId,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          _buildActionButtons(colors),
        ],
      ),
    );
  }

  Widget _buildAvatar(dynamic colors) {
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
                profile.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitials(colors),
              ),
            )
          : _buildInitials(colors),
    );
  }

  Widget _buildInitials(dynamic colors) {
    return Center(
      child: Text(
        profile.initials,
        style: GoogleFonts.inter(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildActionButtons(dynamic colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // _buildActionButton(
        //   icon: Icons.qr_code_2_outlined,
        //   colors: colors,
        //   onTap: onQRTap,
        // ),
        SizedBox(width: 8.w),
        // More menu button
        _buildActionButton(
          icon: Icons.more_vert,
          colors: colors,
          onTap: onMenuTap,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required dynamic colors,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border.all(color: ColorPalette.slate500),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(icon, size: 20.sp, color: colors.primaryBlue),
      ),
    );
  }
}
