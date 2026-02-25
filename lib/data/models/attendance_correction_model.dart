import 'package:hrd_app/core/utils/format_date.dart';

class AttendanceCorrectionModel {
  final String? id;
  final String? attendanceCorrectionRequestNo;
  final String? fileAttachmentCorrection;
  final String? statusAttendanceCorrection;
  final String? startDateAttendanceCorrection;
  final String? endDateAttendanceCorrection;
  final String? employeeId;
  final String? employeeName;
  final String? employeeCode;
  final String? createdBy;
  final String? profile;
  final String? createdByPhoto;
  final String? fileNameCorrection;
  final String? companyName;
  final List<AttendanceCorrectionDetailModel> details;
  final List<ApproverRequestModel> approvers;

  AttendanceCorrectionModel({
    this.id,
    this.attendanceCorrectionRequestNo,
    this.fileAttachmentCorrection,
    this.statusAttendanceCorrection,
    this.startDateAttendanceCorrection,
    this.endDateAttendanceCorrection,
    this.employeeId,
    this.employeeName,
    this.employeeCode,
    this.createdBy,
    this.profile,
    this.createdByPhoto,
    this.fileNameCorrection,
    this.companyName,
    this.details = const [],
    this.approvers = const [],
  });

  factory AttendanceCorrectionModel.fromJson(Map<String, dynamic> json) {
    final detailList = json['attendance_correction_detail'] as List? ?? [];
    final approverList = json['approver_request'] as List? ?? [];

    return AttendanceCorrectionModel(
      id: json['id'] as String?,
      attendanceCorrectionRequestNo:
          json['attendance_correction_request_no'] as String?,
      fileAttachmentCorrection: json['file_attachment_correction'] as String?,
      statusAttendanceCorrection:
          json['status_attendance_correction'] as String?,
      startDateAttendanceCorrection:
          json['start_date_attendance_correction'] as String?,
      endDateAttendanceCorrection:
          json['end_date_attendance_correction'] as String?,
      employeeId: json['employee_id'] as String?,
      employeeName: json['employee_name'] as String?,
      employeeCode: json['employee_code'] as String?,
      createdBy: json['created_by'] as String?,
      profile: json['profile'] as String?,
      createdByPhoto: json['created_by_photo'] as String?,
      fileNameCorrection: json['file_name_correction'] as String?,
      companyName: json['company_name'] as String?,
      details: detailList
          .map(
            (e) => AttendanceCorrectionDetailModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      approvers: approverList
          .map((e) => ApproverRequestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Display helpers
  String get displayRequestNo => attendanceCorrectionRequestNo ?? '-';

  String get displayEmployeeName => employeeName ?? '-';

  String get displayCreatedBy => createdBy ?? '-';

  String get displayStatus => statusAttendanceCorrection ?? 'UNKNOWN';

  String get displayStartDate =>
      FormatDate.fromString(startDateAttendanceCorrection);

  String get displayEndDate =>
      FormatDate.fromString(endDateAttendanceCorrection);

  String get displayDateRange => FormatDate.dateRangeFromString(
    startDateAttendanceCorrection,
    endDateAttendanceCorrection,
  );

  bool get isUnverified =>
      statusAttendanceCorrection?.toUpperCase() == 'UNVERIFIED';

  bool get isApproved =>
      statusAttendanceCorrection?.toUpperCase() == 'APPROVED';

  bool get isRejected =>
      statusAttendanceCorrection?.toUpperCase() == 'REJECTED';
}

class AttendanceCorrectionDetailModel {
  final String? id;
  final String? shiftDailyCodeCorrection;
  final String? dateScheduleCorrection;
  final String? checkInBeforeCorrection;
  final String? checkOutBeforeCorrection;
  final String? checkInAfterCorrection;
  final String? checkOutAfterCorrection;
  final String? remarkAttendanceCorrection;
  final String? statusDetailAttendanceCorrection;
  final String? shiftDailyCodeBefore;

  AttendanceCorrectionDetailModel({
    this.id,
    this.shiftDailyCodeCorrection,
    this.dateScheduleCorrection,
    this.checkInBeforeCorrection,
    this.checkOutBeforeCorrection,
    this.checkInAfterCorrection,
    this.checkOutAfterCorrection,
    this.remarkAttendanceCorrection,
    this.statusDetailAttendanceCorrection,
    this.shiftDailyCodeBefore,
  });

  factory AttendanceCorrectionDetailModel.fromJson(Map<String, dynamic> json) {
    return AttendanceCorrectionDetailModel(
      id: json['id'] as String?,
      shiftDailyCodeCorrection: json['shift_daily_code_correction'] as String?,
      dateScheduleCorrection: json['date_schedule_correction'] as String?,
      checkInBeforeCorrection: json['check_in_before_correction'] as String?,
      checkOutBeforeCorrection: json['check_out_before_correction'] as String?,
      checkInAfterCorrection: json['check_in_after_correction'] as String?,
      checkOutAfterCorrection: json['check_out_after_correction'] as String?,
      remarkAttendanceCorrection:
          json['remark_attendance_correction'] as String?,
      statusDetailAttendanceCorrection:
          json['status_detail_attendance_correction'] as String?,
      shiftDailyCodeBefore: json['shift_daily_code_before'] as String?,
    );
  }

  String get displayDate => FormatDate.fromString(dateScheduleCorrection);
}

class ApproverRequestModel {
  final String? approverId;
  final String? userName;
  final String? jobGradeName;
  final String? statusAttendanceCorrection;
  final String? remarkAttendanceCorrection;
  final String? approvalAt;
  final String? approverProfile;

  ApproverRequestModel({
    this.approverId,
    this.userName,
    this.jobGradeName,
    this.statusAttendanceCorrection,
    this.remarkAttendanceCorrection,
    this.approvalAt,
    this.approverProfile,
  });

  factory ApproverRequestModel.fromJson(Map<String, dynamic> json) {
    return ApproverRequestModel(
      approverId: json['approver_id'] as String?,
      userName: json['user_name'] as String?,
      jobGradeName: json['job_grade_name'] as String?,
      statusAttendanceCorrection:
          json['status_attendance_correction'] as String?,
      remarkAttendanceCorrection:
          json['remark_attendance_correction'] as String?,
      approvalAt: json['approval_at'] as String?,
      approverProfile: json['approver_profile'] as String?,
    );
  }

  /// Format approval date: "2025-05-26 11:13:00" → "26 Mei 2025 11:13"
  String get displayApprovalDate {
    if (approvalAt == null || approvalAt!.isEmpty) return '';
    try {
      final dt = DateTime.parse(approvalAt!);
      final date = FormatDate.shortDateWithYear(dt);
      final time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      return '$date $time';
    } catch (e) {
      return approvalAt!;
    }
  }
}
