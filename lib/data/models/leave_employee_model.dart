import 'package:hrd_app/core/utils/format_date.dart';
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
  final String? leaveTypeName;
  final int? remainingLeave;
  final String? startValidDateLeave;
  final String? endValidDateLeave;
  final String? fileNameLeave;
  final List<dynamic>? historyApprover;

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
    this.leaveTypeName,
    this.remainingLeave,
    this.startValidDateLeave,
    this.endValidDateLeave,
    this.fileNameLeave,
    this.historyApprover,
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
      leaveTypeName: json['leave_type_name'] as String?,
      remainingLeave: json['remaining_leave'] as int?,
      startValidDateLeave: json['start_valid_date_leave'] as String?,
      endValidDateLeave: json['end_valid_date_leave'] as String?,
      fileNameLeave: json['file_name_leave'] as String?,
      historyApprover: json['history_approver'] as List<dynamic>?,
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
      'leave_type_name': leaveTypeName,
      'remaining_leave': remainingLeave,
      'start_valid_date_leave': startValidDateLeave,
      'end_valid_date_leave': endValidDateLeave,
      'file_name_leave': fileNameLeave,
      'history_approver': historyApprover,
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
  String get displayLeaveTypeName =>
      leaveType?.displayName ?? leaveTypeName ?? '-';

  /// Display leave type code untuk UI
  String get displayLeaveTypeCode => leaveType?.displayCode ?? '-';

  /// Display total days untuk UI
  String get displayTotalDays {
    if (totalDays == null) return '-';
    return '$totalDays hari';
  }

  /// Display date range untuk UI (misal: "26 Jan 2026 - 26 Jan 2026")
  String get displayDateRange =>
      FormatDate.dateRangeFromString(startLeave, endLeave);

  /// Format start date untuk UI (misal: "15 Jan 2026")
  String get formattedStartDate => FormatDate.fromString(startLeave);

  /// Format end date untuk UI (misal: "15 Jan 2026")
  String get formattedEndDate => FormatDate.fromString(endLeave);

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

  /// Display remaining leave dengan periode validitas
  /// Format: "12 Hari (14 Jan 2026 - 21 Dec 2026)"
  String get displayRemainingLeave {
    if (remainingLeave == null) return '-';
    final validityPeriod = FormatDate.dateRangeFromString(
      startValidDateLeave,
      endValidDateLeave,
    );
    return '$remainingLeave Hari ($validityPeriod)';
  }
}
