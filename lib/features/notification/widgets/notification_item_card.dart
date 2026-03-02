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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: item.isRead
                ? colors.divider
                : colors.primaryBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Avatar + Name/Position + Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(name: item.displayName, size: 40.w, fontSize: 16.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayName,
                        style: AppTextStyles.bodyMedium(colors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'LEADER',
                        style: AppTextStyles.caption(colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  item.timeNotification ?? '',
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
              ],
            ),

            SizedBox(height: 12.h),
            Divider(height: 1, color: colors.divider),
            SizedBox(height: 12.h),

            // Row 2: Request number + Status
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
                _buildStatusText(),
              ],
            ),

            // Row 3: Body text
            if (item.bodyNotification != null &&
                item.bodyNotification!.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                item.bodyNotification!,
                style: AppTextStyles.caption(colors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    final title = (item.titleNotification ?? '').toLowerCase();

    String label;
    Color textColor;

    if (title.contains('approved') || title.contains('approve')) {
      label = 'Disetujui Sepenuhnya';
      textColor = const Color(0xFF28A745);
    } else if (title.contains('rejected') || title.contains('reject')) {
      label = 'Ditolak';
      textColor = const Color(0xFFDC3545);
    } else if (title.contains('revised') || title.contains('revise')) {
      label = 'Direvisi';
      textColor = const Color(0xFFD68910);
    } else if (title.contains('cancelled') || title.contains('cancel')) {
      label = 'Dibatalkan';
      textColor = const Color(0xFFDC3545);
    } else if (title.contains('unverified')) {
      label = 'Belum diverifikasi';
      textColor = const Color(0xFFD68910);
    } else {
      label = 'Menunggu';
      textColor = const Color(0xFFD68910);
    }

    return Text(
      label,
      style: AppTextStyles.bodyMedium(textColor).copyWith(fontSize: 13.sp),
    );
  }
}
