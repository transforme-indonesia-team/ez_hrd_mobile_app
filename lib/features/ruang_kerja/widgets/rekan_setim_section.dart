import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';

class RekanSetimSection extends StatelessWidget {
  final List<TeamMember> members;
  final VoidCallback? onLainnyaTap;
  final Function(TeamMember)? onMemberTap;

  const RekanSetimSection({
    super.key,
    required this.members,
    this.onLainnyaTap,
    this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.background,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rekan Setim hari ini',
                          style: AppTextStyles.bodySemiBold(colors.textPrimary),
                        ),
                        TextButton(
                          onPressed: onLainnyaTap ?? () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Lainnya',
                            style: AppTextStyles.bodyMedium(colors.primaryBlue),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Berikan tugas kepada tim Anda dengan mengklik profil mereka di bawah.',
                      style: AppTextStyles.body(colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: members.map((member) {
                return Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: _buildMemberItem(context, member),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(BuildContext context, TeamMember member) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () => onMemberTap?.call(member),
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
              border: Border.all(color: colors.divider, width: 1),
            ),
            child: Center(
              child: Text(
                member.initials,
                style: AppTextStyles.bodySemiBold(colors.textSecondary),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(member.name, style: AppTextStyles.body(colors.textPrimary)),
        ],
      ),
    );
  }
}

class TeamMember {
  final String name;
  final String initials;
  final String? avatarUrl;

  const TeamMember({
    required this.name,
    required this.initials,
    this.avatarUrl,
  });
}
