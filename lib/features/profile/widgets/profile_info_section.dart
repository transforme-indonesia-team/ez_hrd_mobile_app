import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/features/profile/models/profile_detail_model.dart';

class ProfileInfoSection extends StatelessWidget {
  final String? company;
  final String? organizationName;
  final List<SocialMediaLink> socialMediaLinks;
  final VoidCallback? onEditSocialMedia;

  const ProfileInfoSection({
    super.key,
    this.company,
    this.organizationName,
    this.socialMediaLinks = const [],
    this.onEditSocialMedia,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.appBar,
        // color: Colors.red,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Ketenagakerjaan Section
          _buildSectionTitle('INFO KETENAGAKERJAAN', colors),
          SizedBox(height: 12.h),
          _buildCompanyInfo(colors),

          SizedBox(height: 12.h),
          // Divider(color: colors.divider, height: 1),
          // SizedBox(height: 12.h),

          // Media Sosial Section
          // _buildSectionTitle('MEDIA SOSIAL', colors),
          // SizedBox(height: 12.h),
          // _buildSocialMediaIcons(colors),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeColors colors) {
    return Text(title, style: AppTextStyles.captionMedium(colors.textPrimary));
  }

  Widget _buildCompanyInfo(ThemeColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.business_outlined, size: 18.sp, color: ColorPalette.gray500),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company ?? '-',
                style: AppTextStyles.smallMedium(colors.textPrimary),
              ),
              SizedBox(height: 2.h),
              Text(
                organizationName ?? '-',
                style: AppTextStyles.captionMedium(colors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildSocialMediaIcons(dynamic colors) {
  //   return Row(
  //     children: [
  //       // Facebook
  //       _buildSocialIcon(Icons.facebook_outlined, colors),
  //       SizedBox(width: 10.w),
  //       // X (Twitter)
  //       _buildSocialIcon(Icons.close, colors),
  //       SizedBox(width: 10.w),
  //       // Instagram
  //       _buildSocialIcon(Icons.camera_alt_outlined, colors),
  //       SizedBox(width: 10.w),
  //       // WhatsApp
  //       _buildSocialIcon(Icons.message_outlined, colors),
  //       SizedBox(width: 10.w),
  //       // LinkedIn
  //       Icon(Icons.work_outline, size: 20.sp, color: colors.textSecondary),

  //       const Spacer(),

  //       // Edit button
  //       InkWell(
  //         onTap: onEditSocialMedia,
  //         borderRadius: BorderRadius.circular(4.r),
  //         child: Padding(
  //           padding: EdgeInsets.all(4.w),
  //           child: Icon(
  //             Icons.edit_outlined,
  //             size: 16.sp,
  //             color: ColorPalette.gray400,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildSocialIcon(IconData icon, dynamic colors) {
  //   return Icon(icon, size: 20.sp, color: colors.textSecondary);
  // }
}
