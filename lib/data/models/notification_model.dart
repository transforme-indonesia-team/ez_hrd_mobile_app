import 'package:flutter/material.dart';

/// A single notification item from the API
/// Items are domain objects (leave, overtime, correction, cancellation)
class NotificationItem {
  final String? id;
  final String? employeeId;
  final String? employeeName;
  final String? profile;
  final String? createdBy;
  final String? createdByPhoto;
  final String? companyName;
  final String? status;
  final String? remark;
  final String? fileAttachment;
  final String? fileName;

  // Request numbers (only one will be set based on category)
  final String? leaveRequestNo;
  final String? overtimeRequestNo;
  final String? attendanceCorrectionRequestNo;
  final String? leaveCancellationRequestNo;

  // Leave-specific
  final String? leaveEmployeeId;
  final String? startLeave;
  final String? endLeave;
  final String? leaveTypeName;
  final int? totalDays;
  final int? remainingLeave;

  // Overtime-specific
  final String? dateOvertime;
  final String? startOvertime;
  final String? endOvertime;
  final int? totalMinutes;

  // Correction-specific
  final String? startDateCorrection;
  final String? endDateCorrection;

  // Cancellation-specific
  final String? leaveCancellationId;

  // Approvers
  final List<Map<String, dynamic>> approverRequest;

  // Read state (for markAsRead)
  final bool isRead;

  NotificationItem({
    this.id,
    this.employeeId,
    this.employeeName,
    this.profile,
    this.createdBy,
    this.createdByPhoto,
    this.companyName,
    this.status,
    this.remark,
    this.fileAttachment,
    this.fileName,
    this.leaveRequestNo,
    this.overtimeRequestNo,
    this.attendanceCorrectionRequestNo,
    this.leaveCancellationRequestNo,
    this.leaveEmployeeId,
    this.startLeave,
    this.endLeave,
    this.leaveTypeName,
    this.totalDays,
    this.remainingLeave,
    this.dateOvertime,
    this.startOvertime,
    this.endOvertime,
    this.totalMinutes,
    this.startDateCorrection,
    this.endDateCorrection,
    this.leaveCancellationId,
    this.approverRequest = const [],
    this.isRead = false,
  });

  /// Parse from leave_employee item
  factory NotificationItem.fromLeaveJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String?,
      leaveRequestNo: json['leave_request_no'] as String?,
      employeeId: json['employee_id'] as String?,
      employeeName: json['employee_name'] as String?,
      profile: json['profile'] as String?,
      createdBy: json['created_by'] as String?,
      createdByPhoto: json['created_by_photo'] as String?,
      companyName: json['company_name'] as String?,
      status: json['status'] as String?,
      remark: json['remark_leave'] as String?,
      fileAttachment: json['file_attachment_leave'] as String?,
      fileName: json['file_name_leave'] as String?,
      startLeave: json['start_leave'] as String?,
      endLeave: json['end_leave'] as String?,
      leaveTypeName: json['leave_type_name'] as String?,
      totalDays: json['total_days'] as int?,
      remainingLeave: json['remaining_leave'] as int?,
      approverRequest: _parseApprovers(json['approver_request']),
    );
  }

  /// Parse from overtime_employee item
  factory NotificationItem.fromOvertimeJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String?,
      overtimeRequestNo: json['overtime_request_no'] as String?,
      employeeId: json['employee_id'] as String?,
      employeeName: json['employee_name'] as String?,
      profile: json['profile'] as String?,
      createdBy: json['created_by'] as String?,
      createdByPhoto: json['created_by_photo'] as String?,
      companyName: json['company_name'] as String?,
      status: json['status'] as String?,
      remark: json['remark_overtime'] as String?,
      fileAttachment: json['file_attachment_overtime'] as String?,
      fileName: json['file_name_overtime'] as String?,
      dateOvertime: json['date_overtime'] as String?,
      startOvertime: json['start_overtime'] as String?,
      endOvertime: json['end_overtime'] as String?,
      totalMinutes: json['total_minutes'] as int?,
      approverRequest: _parseApprovers(json['approver_request']),
    );
  }

  /// Parse from attendance_correction_request item
  factory NotificationItem.fromCorrectionJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String?,
      attendanceCorrectionRequestNo:
          json['attendance_correction_request_no'] as String?,
      employeeId: json['employee_id'] as String?,
      employeeName: json['employee_name'] as String?,
      profile: json['profile'] as String?,
      createdBy: json['created_by'] as String?,
      createdByPhoto: json['created_by_photo'] as String?,
      companyName: json['company_name'] as String?,
      status: json['status_attendance_correction'] as String?,
      fileAttachment: json['file_attachment_correction'] as String?,
      fileName: json['file_name_correction'] as String?,
      startDateCorrection: json['start_date_attendance_correction'] as String?,
      endDateCorrection: json['end_date_attendance_correction'] as String?,
      approverRequest: _parseApprovers(json['approver_request']),
    );
  }

  /// Parse from leave_cancellation item
  factory NotificationItem.fromCancellationJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String?,
      leaveCancellationId: json['id'] as String?,
      leaveCancellationRequestNo:
          json['leave_cancellation_request_no'] as String?,
      leaveEmployeeId: json['leave_employee_id'] as String?,
      employeeName: json['employee_name'] as String?,
      profile: json['profile'] as String?,
      createdBy: json['created_by'] as String?,
      createdByPhoto: json['created_by_photo'] as String?,
      companyName: json['company_name'] as String?,
      status: json['status_leave_cancellation'] as String?,
      remark: json['remark_leave_cancellation'] as String?,
      fileAttachment: json['file_attachment_leave_cancellation'] as String?,
      fileName: json['file_name_leave'] as String?,
      approverRequest: _parseApprovers(json['approver_request']),
    );
  }

  static List<Map<String, dynamic>> _parseApprovers(dynamic value) {
    if (value == null || value is! List) return [];
    return value.cast<Map<String, dynamic>>();
  }

  /// Get the request number to display
  String get displayRequestNo {
    return leaveRequestNo ??
        overtimeRequestNo ??
        attendanceCorrectionRequestNo ??
        leaveCancellationRequestNo ??
        '-';
  }

  /// Get display name (employee or creator)
  String get displayName => employeeName ?? createdBy ?? '-';

  /// Get display photo
  String? get displayPhoto => profile ?? createdByPhoto;

  /// Get status label in Indonesian
  String get displayStatus {
    switch (status?.toUpperCase()) {
      case 'APPROVED':
        return 'Disetujui';
      case 'PARTIALLY_APPROVED':
        return 'Disetujui Sebagian';
      case 'REJECTED':
        return 'Ditolak';
      case 'REVISED':
      case 'REVISE':
        return 'Direvisi';
      case 'CANCELLED':
        return 'Dibatalkan';
      case 'UNVERIFIED':
        return 'Menunggu';
      default:
        return 'Menunggu';
    }
  }

  /// Get status color
  Color get statusColor {
    switch (status?.toUpperCase()) {
      case 'APPROVED':
        return const Color(0xFF28A745);
      case 'PARTIALLY_APPROVED':
        return const Color(0xFFD68910);
      case 'REJECTED':
      case 'CANCELLED':
        return const Color(0xFFDC3545);
      case 'REVISED':
      case 'REVISE':
        return const Color(0xFFD68910);
      case 'UNVERIFIED':
        return const Color(0xFFD68910);
      default:
        return const Color(0xFFD68910);
    }
  }

  /// Create a copy with isRead set to true
  NotificationItem copyWithRead() {
    return NotificationItem(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      profile: profile,
      createdBy: createdBy,
      createdByPhoto: createdByPhoto,
      companyName: companyName,
      status: status,
      remark: remark,
      fileAttachment: fileAttachment,
      fileName: fileName,
      leaveRequestNo: leaveRequestNo,
      overtimeRequestNo: overtimeRequestNo,
      attendanceCorrectionRequestNo: attendanceCorrectionRequestNo,
      leaveCancellationRequestNo: leaveCancellationRequestNo,
      leaveEmployeeId: leaveEmployeeId,
      startLeave: startLeave,
      endLeave: endLeave,
      leaveTypeName: leaveTypeName,
      totalDays: totalDays,
      remainingLeave: remainingLeave,
      dateOvertime: dateOvertime,
      startOvertime: startOvertime,
      endOvertime: endOvertime,
      totalMinutes: totalMinutes,
      startDateCorrection: startDateCorrection,
      endDateCorrection: endDateCorrection,
      leaveCancellationId: leaveCancellationId,
      approverRequest: approverRequest,
      isRead: true,
    );
  }

  /// Create a copy with a new status
  NotificationItem copyWithStatus(String newStatus) {
    return NotificationItem(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      profile: profile,
      createdBy: createdBy,
      createdByPhoto: createdByPhoto,
      companyName: companyName,
      status: newStatus,
      remark: remark,
      fileAttachment: fileAttachment,
      fileName: fileName,
      leaveRequestNo: leaveRequestNo,
      overtimeRequestNo: overtimeRequestNo,
      attendanceCorrectionRequestNo: attendanceCorrectionRequestNo,
      leaveCancellationRequestNo: leaveCancellationRequestNo,
      leaveEmployeeId: leaveEmployeeId,
      startLeave: startLeave,
      endLeave: endLeave,
      leaveTypeName: leaveTypeName,
      totalDays: totalDays,
      remainingLeave: remainingLeave,
      dateOvertime: dateOvertime,
      startOvertime: startOvertime,
      endOvertime: endOvertime,
      totalMinutes: totalMinutes,
      startDateCorrection: startDateCorrection,
      endDateCorrection: endDateCorrection,
      leaveCancellationId: leaveCancellationId,
      approverRequest: approverRequest,
      isRead: isRead,
    );
  }
}

/// A grouped category of notifications
class NotificationCategory {
  final String key;
  final String label;
  final IconData icon;
  final int itemCount;
  final List<NotificationItem> items;

  NotificationCategory({
    required this.key,
    required this.label,
    required this.icon,
    required this.itemCount,
    required this.items,
  });

  /// Parse API response records into categories
  /// New format: records.{category}_count + records.{category}[]
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
      final key = entry.key;
      final itemCount = records['${key}_count'] as int? ?? 0;
      final rawItems = records[key] as List? ?? [];

      List<NotificationItem> items;
      switch (key) {
        case 'leave_employee':
          items = rawItems
              .map(
                (e) =>
                    NotificationItem.fromLeaveJson(e as Map<String, dynamic>),
              )
              .toList();
          break;
        case 'overtime_employee':
          items = rawItems
              .map(
                (e) => NotificationItem.fromOvertimeJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();
          break;
        case 'attendance_correction_request':
          items = rawItems
              .map(
                (e) => NotificationItem.fromCorrectionJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();
          break;
        case 'leave_cancellation':
          items = rawItems
              .map(
                (e) => NotificationItem.fromCancellationJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();
          break;
        default:
          items = [];
      }

      categories.add(
        NotificationCategory(
          key: key,
          label: entry.value['label'] as String,
          icon: entry.value['icon'] as IconData,
          itemCount: itemCount,
          items: items,
        ),
      );
    }

    // Sort by item count descending
    categories.sort((a, b) => b.itemCount.compareTo(a.itemCount));

    return categories;
  }
}
