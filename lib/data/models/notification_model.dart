import 'package:flutter/material.dart';

/// A single notification item from the API
class NotificationItem {
  final String? id;
  final String? attendanceCorrectionRequestId;
  final String? leaveEmployeeId;
  final String? overtimeEmployeeId;
  final String? leaveCancellationId;
  final String? employeeId;
  final String? titleNotification;
  final String? bodyNotification;
  final bool isRead;
  final String? notifType;
  final String? employeeName;
  final String? leaveRequestNo;
  final String? overtimeRequestNo;
  final String? attendanceCorrectionRequestNo;
  final String? timeNotification;

  NotificationItem({
    this.id,
    this.attendanceCorrectionRequestId,
    this.leaveEmployeeId,
    this.overtimeEmployeeId,
    this.leaveCancellationId,
    this.employeeId,
    this.titleNotification,
    this.bodyNotification,
    this.isRead = false,
    this.notifType,
    this.employeeName,
    this.leaveRequestNo,
    this.overtimeRequestNo,
    this.attendanceCorrectionRequestNo,
    this.timeNotification,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String?,
      attendanceCorrectionRequestId:
          json['attendance_correction_request_id'] as String?,
      leaveEmployeeId: json['leave_employee_id'] as String?,
      overtimeEmployeeId: json['overtime_employee_id'] as String?,
      leaveCancellationId: json['leave_cancellation_id'] as String?,
      employeeId: json['employee_id'] as String?,
      titleNotification: json['title_notification'] as String?,
      bodyNotification: json['body_notification'] as String?,
      isRead: json['is_read_notification'] == true,
      notifType: json['notif_type'] as String?,
      employeeName: json['employee_name'] as String?,
      leaveRequestNo: json['leave_request_no'] as String?,
      overtimeRequestNo: json['overtime_request_no'] as String?,
      attendanceCorrectionRequestNo:
          json['attendance_correction_request_no'] as String?,
      timeNotification: json['time_notification'] as String?,
    );
  }

  /// Get the request number to display
  String get displayRequestNo {
    return leaveRequestNo ??
        overtimeRequestNo ??
        attendanceCorrectionRequestNo ??
        '-';
  }

  /// Get display name
  String get displayName => employeeName ?? '-';
}

/// A grouped category of notifications
class NotificationCategory {
  final String key;
  final String label;
  final IconData icon;
  final int unreadCount;
  final int totalCount;
  final List<NotificationItem> items;

  NotificationCategory({
    required this.key,
    required this.label,
    required this.icon,
    required this.unreadCount,
    required this.totalCount,
    required this.items,
  });

  /// Parse API response records into categories
  static List<NotificationCategory> fromApiRecords(
    Map<String, dynamic> records,
  ) {
    final categories = <NotificationCategory>[];

    final mapping = {
      'attendance_correction_request': {
        'label': 'Permintaan Koreksi Kehadiran',
        'icon': Icons.schedule,
      },
      'leave_employee': {
        'label': 'Permintaan Cuti Kehadiran',
        'icon': Icons.event_note,
      },
      'overtime_employee': {
        'label': 'Permintaan Lembur',
        'icon': Icons.access_time,
      },
      'leave_cancellation': {
        'label': 'Pembatalan Cuti',
        'icon': Icons.cancel_outlined,
      },
    };

    for (final entry in mapping.entries) {
      final data = records[entry.key];
      if (data == null) continue;

      final unread = data['unread_notif'] as int? ?? 0;
      final total = data['total_notif'] as int? ?? 0;
      final items = (data['data'] as List? ?? [])
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();

      categories.add(
        NotificationCategory(
          key: entry.key,
          label: entry.value['label'] as String,
          icon: entry.value['icon'] as IconData,
          unreadCount: unread,
          totalCount: total,
          items: items,
        ),
      );
    }

    // Sort by unread count descending
    categories.sort((a, b) => b.unreadCount.compareTo(a.unreadCount));

    return categories;
  }
}
