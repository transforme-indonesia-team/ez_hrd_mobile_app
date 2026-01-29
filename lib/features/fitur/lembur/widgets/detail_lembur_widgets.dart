import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';

class DetailSectionHeader extends StatelessWidget {
  final String title;

  const DetailSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: colors.textSubtitle,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class LabelValueColumn extends StatelessWidget {
  final String label;
  final String value;
  final double? fontSize;
  final Widget? icon;
  final CrossAxisAlignment crossAxisAlignment;

  const LabelValueColumn({
    super.key,
    required this.label,
    required this.value,
    this.fontSize,
    this.icon,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.caption(
            colors.textSecondary,
          ).copyWith(fontSize: 12.sp),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, SizedBox(width: 6.w)],
            Flexible(
              child: Text(
                value,
                style: AppTextStyles.body(colors.textPrimary).copyWith(
                  fontWeight: FontWeight.w200,
                  fontSize: fontSize ?? 13.sp,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class UserInfoItem extends StatelessWidget {
  final String label;
  final String name;
  final String role;
  final String? photoUrl;

  const UserInfoItem({
    super.key,
    required this.label,
    required this.name,
    required this.role,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(colors.textSecondary)),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(avatarUrl: photoUrl, name: name, size: 36, fontSize: 12),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium(
                      colors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    role,
                    style: AppTextStyles.caption(
                      colors.textSecondary,
                    ).copyWith(fontSize: 11.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DetailCardItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isBoldValue;

  const DetailCardItem({
    super.key,
    required this.label,
    required this.value,
    this.isBoldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.caption(
            colors.textSecondary,
          ).copyWith(fontSize: 11.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: isBoldValue
              ? AppTextStyles.bodyMedium(
                  colors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp)
              : AppTextStyles.bodyMedium(
                  colors.textPrimary,
                ).copyWith(fontSize: 13.sp),
        ),
      ],
    );
  }
}

class AttendanceTimeCard extends StatelessWidget {
  final String label;
  final String time;
  final bool hasError;
  final Widget? avatar;

  const AttendanceTimeCard({
    super.key,
    required this.label,
    required this.time,
    this.hasError = false,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(colors.textSecondary)),
        SizedBox(height: 8.h),
        Row(
          children: [
            if (avatar != null) ...[avatar!, SizedBox(width: 8.w)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: AppTextStyles.bodyMedium(
                      colors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (hasError)
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 14.sp,
                          color: Colors.red,
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.location_off_outlined,
                          size: 14.sp,
                          color: Colors.red,
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14.sp,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.location_on,
                          size: 14.sp,
                          color: Colors.green,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ApprovalListItem extends StatelessWidget {
  final String name;
  final String role;
  final String status;
  final Color statusColor;
  final String? photoUrl;

  const ApprovalListItem({
    super.key,
    required this.name,
    required this.role,
    required this.status,
    required this.statusColor,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          UserAvatar(avatarUrl: photoUrl, name: name, size: 40, fontSize: 14),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMedium(
                    colors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  role,
                  style: AppTextStyles.caption(colors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              status,
              style: AppTextStyles.caption(
                statusColor,
              ).copyWith(fontWeight: FontWeight.w600, fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SKELETON WIDGETS
// Skeleton version dari setiap widget di atas untuk digunakan saat loading
// =============================================================================

/// Skeleton version dari LabelValueColumn
class LabelValueColumnSkeleton extends StatelessWidget {
  final double valueWidth;

  const LabelValueColumnSkeleton({super.key, this.valueWidth = 80});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: valueWidth.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ],
    );
  }
}

/// Skeleton version dari UserInfoItem
class UserInfoItemSkeleton extends StatelessWidget {
  const UserInfoItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    width: 60.w,
                    height: 11.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Skeleton version dari ApprovalListItem
class ApprovalListItemSkeleton extends StatelessWidget {
  const ApprovalListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  width: 80.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 70.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                width: 90.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton version dari DetailCardItem
class DetailCardItemSkeleton extends StatelessWidget {
  const DetailCardItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60.w,
          height: 11.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: 80.w,
          height: 13.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ],
    );
  }
}

/// Skeleton untuk detail section card (DETAIL PERMINTAAN LEMBUR)
class DetailSectionSkeleton extends StatelessWidget {
  const DetailSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.backgroundDetail,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: 180.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 12.h),
          Divider(color: colors.divider, height: 1, thickness: 1),
          SizedBox(height: 14.h),
          // Tanggal
          Container(
            width: 100.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 4.h),
          // Shift
          Container(
            width: 200.w,
            height: 13.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 2.h),
          // Istirahat
          Container(
            width: 150.w,
            height: 13.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 14.h),
          // Waktu Aktual label
          Container(
            width: 80.w,
            height: 13.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              const Expanded(child: DetailCardItemSkeleton()),
              SizedBox(width: 12.w),
              const Expanded(child: DetailCardItemSkeleton()),
            ],
          ),
          SizedBox(height: 14.h),
          // Lembur label
          Container(
            width: 60.w,
            height: 13.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              const Expanded(child: DetailCardItemSkeleton()),
              SizedBox(width: 12.w),
              const Expanded(child: DetailCardItemSkeleton()),
            ],
          ),
          SizedBox(height: 12.h),
          // Durasi
          Container(
            width: 220.w,
            height: 11.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ),
    );
  }
}
