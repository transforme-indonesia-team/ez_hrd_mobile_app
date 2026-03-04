import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';
import 'package:hrd_app/data/models/notification_model.dart';

class NotificationItemCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback? onTap;

  const NotificationItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUnread = !item.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isUnread
              ? colors.primaryBlue.withValues(alpha: 0.04)
              : colors.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isUnread
                ? colors.primaryBlue.withValues(alpha: 0.3)
                : colors.divider,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar for unread
              if (isUnread)
                Container(
                  width: 4.w,
                  decoration: BoxDecoration(
                    color: colors.primaryBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      bottomLeft: Radius.circular(12.r),
                    ),
                  ),
                ),

              // Main content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Avatar + Name/Company + Status badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UserAvatar(
                            name: item.displayName,
                            avatarUrl: item.displayPhoto,
                            size: 40.w,
                            fontSize: 16.sp,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.displayName,
                                  style: AppTextStyles.bodyMedium(
                                    colors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  item.companyName ?? '-',
                                  style: AppTextStyles.caption(
                                    colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Status badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: item.statusColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  item.displayStatus,
                                  style: AppTextStyles.xSmall(
                                    item.statusColor,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (isUnread) ...[
                                SizedBox(height: 6.h),
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: colors.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),
                      Divider(height: 1, color: colors.divider),
                      SizedBox(height: 12.h),

                      // Row 2: Request number + Created by
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.displayRequestNo,
                              style: AppTextStyles.bodyMedium(
                                colors.textPrimary,
                              ).copyWith(fontSize: 13.sp),
                            ),
                          ),
                          if (item.createdBy != null)
                            Text(
                              'oleh ${item.createdBy}',
                              style: AppTextStyles.caption(
                                colors.textSecondary,
                              ).copyWith(fontSize: 11.sp),
                            ),
                        ],
                      ),

                      // Row 3: Remark
                      if (item.remark != null && item.remark!.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          item.remark!,
                          style: AppTextStyles.caption(colors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
