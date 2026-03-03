import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/models/notification_model.dart';
import 'package:hrd_app/data/services/notification_service.dart';
import 'package:hrd_app/features/notification/screens/notification_list_screen.dart';
import 'package:hrd_app/features/notification/widgets/empty_notification_state.dart';
import 'package:hrd_app/features/notification/widgets/notification_category_tile.dart';

class NotificationCategoryTab extends StatefulWidget {
  final String notifType;
  final ValueChanged<int>? onUnreadChanged;

  const NotificationCategoryTab({
    super.key,
    required this.notifType,
    this.onUnreadChanged,
  });

  @override
  State<NotificationCategoryTab> createState() =>
      _NotificationCategoryTabState();
}

class _NotificationCategoryTabState extends State<NotificationCategoryTab>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  String? _error;
  List<NotificationCategory> _categories = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await NotificationService().getNotification(
        notifType: widget.notifType,
      );

      final records = response['original']?['records'] ?? response['records'];

      if (records == null || records is List) {
        if (mounted) {
          setState(() {
            _categories = [];
            _isLoading = false;
          });
        }
        return;
      }

      final categories = NotificationCategory.fromApiRecords(
        records as Map<String, dynamic>,
      );

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
        // Notify parent of updated unread count
        final totalUnread = categories.fold(0, (sum, c) => sum + c.unreadCount);
        widget.onUnreadChanged?.call(totalUnread);
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat notifikasi';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: colors.divider),
            SizedBox(height: 12.h),
            Text(_error!, style: AppTextStyles.body(colors.textSecondary)),
            SizedBox(height: 12.h),
            OutlinedButton(
              onPressed: _fetchData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return EmptyNotificationState(
        title: widget.notifType == 'REQUEST'
            ? 'Tidak ada Permintaan'
            : 'Tidak ada Persetujuan',
        subtitle: widget.notifType == 'REQUEST'
            ? 'Kamu belum mengajukan permintaan apa pun'
            : 'Kamu tidak memiliki permintaan yang perlu disetujui',
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.separated(
        itemCount: _categories.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 16.w,
          endIndent: 16.w,
          color: colors.divider,
        ),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return NotificationCategoryTile(
            icon: category.icon,
            label: category.label,
            unreadCount: category.unreadCount,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationListScreen(category: category),
                ),
              );
              // Refresh data when coming back
              _fetchData();
            },
          );
        },
      ),
    );
  }
}
