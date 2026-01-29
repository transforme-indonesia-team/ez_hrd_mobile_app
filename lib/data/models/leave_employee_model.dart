import 'package:hrd_app/data/models/leave_type_model.dart';

/// Model untuk data cuti karyawan
class LeaveEmployeeModel {
  final String id;
  final String? leaveRequestNo;
  final String? employeeId;
  final String? startLeave;
  final String? endLeave;
  final String? remarkLeave;
  final String? fileAttachmentLeave;
  final String? status;
  final int? totalDays;
  final String? leaveTypeId;
  final String? leaveEmployeeCreatedBy;
  final LeaveTypeModel? leaveType;
  final List<dynamic>? approverRequest;
  final String? employeeName;
  final String? profile;
  final String? createdBy;
  final String? createdByPhoto;
  final String? companyName;
  final String? fileNameOvertime;

  const LeaveEmployeeModel({
    required this.id,
    this.leaveRequestNo,
    this.employeeId,
    this.startLeave,
    this.endLeave,
    this.remarkLeave,
    this.fileAttachmentLeave,
    this.status,
    this.totalDays,
    this.leaveTypeId,
    this.leaveEmployeeCreatedBy,
    this.leaveType,
    this.approverRequest,
    this.employeeName,
    this.profile,
    this.createdBy,
    this.createdByPhoto,
    this.companyName,
    this.fileNameOvertime,
  });

  factory LeaveEmployeeModel.fromJson(Map<String, dynamic> json) {
    return LeaveEmployeeModel(
      id: json['id'] as String,
      leaveRequestNo: json['leave_request_no'] as String?,
      employeeId: json['employee_id'] as String?,
      startLeave: json['start_leave'] as String?,
      endLeave: json['end_leave'] as String?,
      remarkLeave: json['remark_leave'] as String?,
      fileAttachmentLeave: json['file_attachment_leave'] as String?,
      status: json['status'] as String?,
      totalDays: json['total_days'] as int?,
      leaveTypeId: json['leave_type_id'] as String?,
      leaveEmployeeCreatedBy: json['leave_employee_created_by'] as String?,
      leaveType: json['leave_type'] != null
          ? LeaveTypeModel.fromJson(json['leave_type'] as Map<String, dynamic>)
          : null,
      approverRequest: json['approver_request'] as List<dynamic>?,
      employeeName: json['employee_name'] as String?,
      profile: json['profile'] as String?,
      createdBy: json['created_by'] as String?,
      createdByPhoto: json['created_by_photo'] as String?,
      companyName: json['company_name'] as String?,
      fileNameOvertime: json['file_name_overtime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leave_request_no': leaveRequestNo,
      'employee_id': employeeId,
      'start_leave': startLeave,
      'end_leave': endLeave,
      'remark_leave': remarkLeave,
      'file_attachment_leave': fileAttachmentLeave,
      'status': status,
      'total_days': totalDays,
      'leave_type_id': leaveTypeId,
      'leave_employee_created_by': leaveEmployeeCreatedBy,
      'leave_type': leaveType?.toJson(),
      'approver_request': approverRequest,
      'employee_name': employeeName,
      'profile': profile,
      'created_by': createdBy,
      'created_by_photo': createdByPhoto,
      'company_name': companyName,
      'file_name_overtime': fileNameOvertime,
    };
  }

  // ============ Helper getters untuk UI ============

  /// Display request number untuk UI
  String get displayRequestNo => leaveRequestNo ?? '-';

  /// Display employee name untuk UI
  String get displayEmployeeName => employeeName ?? '-';

  /// Display company name untuk UI
  String get displayCompanyName => companyName ?? '-';

  /// Display leave type name untuk UI
  String get displayLeaveTypeName => leaveType?.displayName ?? '-';

  /// Display leave type code untuk UI
  String get displayLeaveTypeCode => leaveType?.displayCode ?? '-';

  /// Display total days untuk UI
  String get displayTotalDays {
    if (totalDays == null) return '-';
    return '$totalDays hari';
  }

  /// Display date range untuk UI (misal: "26 Jan 2026 - 26 Jan 2026")
  String get displayDateRange {
    if (startLeave == null && endLeave == null) return '-';
    if (startLeave == endLeave) return formattedStartDate;
    return '$formattedStartDate - $formattedEndDate';
  }

  /// Format start date untuk UI (misal: "15 Jan 2026")
  String get formattedStartDate {
    if (startLeave == null) return '-';
    return _formatDate(startLeave!);
  }

  /// Format end date untuk UI (misal: "15 Jan 2026")
  String get formattedEndDate {
    if (endLeave == null) return '-';
    return _formatDate(endLeave!);
  }

  /// Helper untuk format tanggal dari "2026-01-15" ke "15 Jan 2026"
  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;

      final year = parts[0];
      final month = int.parse(parts[1]);
      final day = parts[2];

      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      if (month < 1 || month > 12) return dateStr;
      return '$day ${months[month]} $year';
    } catch (e) {
      return dateStr;
    }
  }

  /// Display cancellation status untuk UI
  String get cancellationStatus => '-';

  /// Display remark untuk UI
  String get displayRemark => remarkLeave ?? '-';

  /// Display status untuk UI
  String get displayStatus => status ?? '-';

  /// Check apakah ada file attachment
  bool get hasAttachment =>
      fileAttachmentLeave != null && fileAttachmentLeave!.isNotEmpty;

  /// Check apakah status draft
  bool get isDraft => status?.toUpperCase() == 'DRAFT';

  /// Check apakah status approved
  bool get isApproved => status?.toUpperCase() == 'APPROVED';

  /// Check apakah status rejected
  bool get isRejected => status?.toUpperCase() == 'REJECTED';

  /// Check apakah status pending
  bool get isPending => status?.toUpperCase() == 'PENDING';
}
