import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/models/notification_model.dart';
import 'package:hrd_app/data/models/leave_employee_model.dart';
import 'package:hrd_app/data/models/overtime_employee_model.dart';
import 'package:hrd_app/data/services/notification_service.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/screens/daftar_koreksi_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/screens/detail_koreksi_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/cuti/screens/detail_cuti_screen.dart';
import 'package:hrd_app/features/fitur/lembur/screens/detail_lembur_screen.dart';
import 'package:hrd_app/features/notification/widgets/notification_item_card.dart';

class NotificationListScreen extends StatefulWidget {
  final NotificationCategory category;

  const NotificationListScreen({super.key, required this.category});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late List<NotificationItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.category.items);
  }

  Future<void> _markAsRead(NotificationItem item) async {
    if (item.isRead || item.id == null) return;

    try {
      await NotificationService().markAsRead(notificationIds: [item.id!]);

      if (mounted) {
        setState(() {
          final index = _items.indexWhere((i) => i.id == item.id);
          if (index != -1) {
            _items[index] = NotificationItem(
              id: item.id,
              attendanceCorrectionRequestId: item.attendanceCorrectionRequestId,
              leaveEmployeeId: item.leaveEmployeeId,
              overtimeEmployeeId: item.overtimeEmployeeId,
              leaveCancellationId: item.leaveCancellationId,
              employeeId: item.employeeId,
              titleNotification: item.titleNotification,
              bodyNotification: item.bodyNotification,
              isRead: true,
              notifType: item.notifType,
              employeeName: item.employeeName,
              leaveRequestNo: item.leaveRequestNo,
              overtimeRequestNo: item.overtimeRequestNo,
              attendanceCorrectionRequestNo: item.attendanceCorrectionRequestNo,
              timeNotification: item.timeNotification,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  void _onItemTap(NotificationItem item) {
    _markAsRead(item);
    _navigateToDetail(item);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category.label,
          style: AppTextStyles.h3(colors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 60.sp,
                    color: colors.divider,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Tidak ada notifikasi',
                    style: AppTextStyles.body(colors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return NotificationItemCard(
                  item: item,
                  onTap: () => _onItemTap(item),
                );
              },
            ),
    );
  }

  void _navigateToDetail(NotificationItem item) {
    switch (widget.category.key) {
      case 'attendance_correction_request':
        if (item.attendanceCorrectionRequestId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailKoreksiKehadiranScreen(
                correctionId: item.attendanceCorrectionRequestId!,
              ),
            ),
          );
        }
        break;
      case 'leave_employee':
      case 'leave_cancellation':
        if (item.leaveEmployeeId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailCutiScreen(
                detailLeave: LeaveEmployeeModel(id: item.leaveEmployeeId!),
              ),
            ),
          );
        }
        break;
      case 'overtime_employee':
        if (item.overtimeEmployeeId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailLemburScreen(
                detailOvertime: OvertimeEmployeeModel(
                  id: item.overtimeEmployeeId!,
                ),
              ),
            ),
          );
        }
        break;
    }
  }

  // ignore: unused_element
  Widget _buildShowAllButton(ThemeColors colors) {
    return InkWell(
      onTap: () => _navigateToAllList(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(top: BorderSide(color: colors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.open_in_new, size: 16.sp, color: colors.textSecondary),
            SizedBox(width: 8.w),
            Text(
              'Tampilkan Semua',
              style: AppTextStyles.bodyMedium(colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAllList() {
    switch (widget.category.key) {
      case 'attendance_correction_request':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DaftarKoreksiKehadiranScreen(),
          ),
        );
        break;
      default:
        break;
    }
  }
}
