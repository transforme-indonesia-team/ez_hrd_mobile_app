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
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: item.isRead
              ? colors.background
              : colors.primaryBlue.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar, name, time
            Row(
              children: [
                UserAvatar(name: item.displayName, size: 36.w, fontSize: 14.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayName,
                        style: AppTextStyles.bodySemiBold(colors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
            SizedBox(height: 10.h),

            // Request number + status
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
                _buildStatusFromTitle(colors),
              ],
            ),

            // Body text
            if (item.bodyNotification != null &&
                item.bodyNotification!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Text(
                  item.bodyNotification!,
                  style: AppTextStyles.caption(colors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFromTitle(ThemeColors colors) {
    final title = (item.titleNotification ?? '').toLowerCase();

    String label;
    Color textColor;
    Color bgColor;

    if (title.contains('approved') || title.contains('approve')) {
      label = 'Disetujui';
      textColor = const Color(0xFF28A745);
      bgColor = const Color(0xFFD4EDDA);
    } else if (title.contains('rejected') || title.contains('reject')) {
      label = 'Ditolak';
      textColor = const Color(0xFFDC3545);
      bgColor = const Color(0xFFF8D7DA);
    } else if (title.contains('revised') || title.contains('revise')) {
      label = 'Direvisi';
      textColor = const Color(0xFFD68910);
      bgColor = const Color(0xFFFFF3CD);
    } else if (title.contains('cancelled') || title.contains('cancel')) {
      label = 'Dibatalkan';
      textColor = const Color(0xFFDC3545);
      bgColor = const Color(0xFFF8D7DA);
    } else if (title.contains('unverified')) {
      label = 'Belum diverifikasi';
      textColor = const Color(0xFF4338CA);
      bgColor = const Color(0xFFE0E7FF);
    } else {
      label = 'Menunggu';
      textColor = const Color(0xFFD68910);
      bgColor = const Color(0xFFFFF3CD);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(textColor).copyWith(fontSize: 11.sp),
      ),
    );
  }
}
