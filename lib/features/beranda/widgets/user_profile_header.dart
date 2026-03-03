import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/color_palette.dart';
import 'package:hrd_app/core/widgets/user_avatar.dart';
import 'package:hrd_app/data/services/notification_service.dart';

class UserProfileHeader extends StatefulWidget {
  final String name;
  final String? avatarUrl;
  final String position;
  final String? avatarInitials;
  final Future<void> Function()? onNotificationTap;

  const UserProfileHeader({
    super.key,
    required this.name,
    this.avatarUrl,
    required this.position,
    this.avatarInitials,
    this.onNotificationTap,
  });

  @override
  State<UserProfileHeader> createState() => _UserProfileHeaderState();
}

class _UserProfileHeaderState extends State<UserProfileHeader> {
  int _notifCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotifCount();
  }

  Future<void> _fetchNotifCount() async {
    try {
      final response = await NotificationService().getCountNotification();
      final count = response['original']?['records']?['total'] ?? 0;
      if (mounted) {
        setState(() {
          _notifCount = count is int ? count : 0;
        });
      }
    } catch (e) {
      debugPrint('Error fetching notification count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: colors.background,
      child: Row(
        children: [
          UserAvatar(
            avatarUrl: widget.avatarUrl,
            name: widget.name,
            size: 48,
            fontSize: 16,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name, style: AppTextStyles.h4(colors.textPrimary)),
                SizedBox(height: 2.h),
                Text(
                  widget.position,
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
              ],
            ),
          ),
          // Bell icon with badge
          GestureDetector(
            onTap: () async {
              await widget.onNotificationTap?.call();
              _fetchNotifCount();
            },
            child: SizedBox(
              width: 40.w,
              height: 40.w,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.notifications,
                      color: ColorPalette.slate500,
                      size: 24.sp,
                    ),
                  ),
                  if (_notifCount > 0)
                    Positioned(
                      right: 2.w,
                      top: 2.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8751A),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18.w,
                          minHeight: 16.h,
                        ),
                        child: Text(
                          _notifCount > 99 ? '99+' : '$_notifCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
