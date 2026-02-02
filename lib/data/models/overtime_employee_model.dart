import 'package:hrd_app/core/utils/format_date.dart';

class OvertimeEmployeeModel {
  final String id;
  final String? overtimeRequestNo;
  final String? employeeId;
  final String? dateOvertime;
  final String? startOvertime;
  final String? endOvertime;
  final String? remarkOvertime;
  final String? fileAttachmentOvertime;
  final String? status;
  final int? totalMinutes;
  final String? overtimeEmployeeCreatedBy;
  final String? overtimeIndex;
  final String? overtimeIndex1;
  final String? overtimeIndex2;
  final List<dynamic>? approverRequest;
  final String? employeeName;
  final String? profile;
  final String? createdBy;
  final String? createdByPhoto;
  final String? companyName;
  final String? fileNameOvertime;

  const OvertimeEmployeeModel({
    required this.id,
    this.overtimeRequestNo,
    this.employeeId,
    this.dateOvertime,
    this.startOvertime,
    this.endOvertime,
    this.remarkOvertime,
    this.fileAttachmentOvertime,
    this.status,
    this.totalMinutes,
    this.overtimeEmployeeCreatedBy,
    this.overtimeIndex,
    this.overtimeIndex1,
    this.overtimeIndex2,
    this.approverRequest,
    this.employeeName,
    this.profile,
    this.createdBy,
    this.createdByPhoto,
    this.companyName,
    this.fileNameOvertime,
  });

  factory OvertimeEmployeeModel.fromJson(Map<String, dynamic> json) {
    return OvertimeEmployeeModel(
      id: json['id'] as String,
      overtimeRequestNo: json['overtime_request_no'] as String?,
      employeeId: json['employee_id'] as String?,
      dateOvertime: json['date_overtime'] as String?,
      startOvertime: json['start_overtime'] as String?,
      endOvertime: json['end_overtime'] as String?,
      remarkOvertime: json['remark_overtime'] as String?,
      fileAttachmentOvertime: json['file_attachment_overtime'] as String?,
      status: json['status'] as String?,
      totalMinutes: json['total_minutes'] as int?,
      overtimeEmployeeCreatedBy:
          json['overtime_employee_created_by'] as String?,
      overtimeIndex: json['overtime_index'] as String?,
      overtimeIndex1: json['overtime_index_1'] as String?,
      overtimeIndex2: json['overtime_index_2'] as String?,
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
      'overtime_request_no': overtimeRequestNo,
      'employee_id': employeeId,
      'date_overtime': dateOvertime,
      'start_overtime': startOvertime,
      'end_overtime': endOvertime,
      'remark_overtime': remarkOvertime,
      'file_attachment_overtime': fileAttachmentOvertime,
      'status': status,
      'total_minutes': totalMinutes,
      'overtime_employee_created_by': overtimeEmployeeCreatedBy,
      'overtime_index': overtimeIndex,
      'overtime_index_1': overtimeIndex1,
      'overtime_index_2': overtimeIndex2,
      'approver_request': approverRequest,
      'employee_name': employeeName,
      'profile': profile,
      'created_by': createdBy,
      'created_by_photo': createdByPhoto,
      'company_name': companyName,
      'file_name_overtime': fileNameOvertime,
    };
  }

  String get displayOvertimeRequestNo => overtimeRequestNo ?? '-';
  String get displayEmployeeName => employeeName ?? '-';
  String get displayStatus => status ?? '-';
  String get displayDateOvertime => FormatDate.fromString(dateOvertime);
  String get displayTimeRange =>
      '${startOvertime ?? '-'} - ${endOvertime ?? '-'}';

  bool get isDraft => status == 'DRAFT';
  bool get hasAttachment =>
      fileAttachmentOvertime != null && fileAttachmentOvertime!.isNotEmpty;
}

/// Model untuk detail section dari API response
class OvertimeDetailModel {
  final String? shiftDailyCode;
  final String? startShiftTime;
  final String? endShiftTime;
  final String? checkIn;
  final String? checkOut;
  final String? attendanceLocationIn;
  final String? attendanceLocationOut;
  final String? attendancePhotoIn;
  final String? attendancePhotoOut;

  const OvertimeDetailModel({
    this.shiftDailyCode,
    this.startShiftTime,
    this.endShiftTime,
    this.checkIn,
    this.checkOut,
    this.attendanceLocationIn,
    this.attendanceLocationOut,
    this.attendancePhotoIn,
    this.attendancePhotoOut,
  });

  factory OvertimeDetailModel.fromJson(Map<String, dynamic> json) {
    return OvertimeDetailModel(
      shiftDailyCode: json['shift_daily_code'] as String?,
      startShiftTime: json['start_shift_time'] as String?,
      endShiftTime: json['end_shift_time'] as String?,
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
      attendanceLocationIn: json['attendance_location_in'] as String?,
      attendanceLocationOut: json['attendance_location_out'] as String?,
      attendancePhotoIn: json['attendance_photo_in'] as String?,
      attendancePhotoOut: json['attendance_photo_out'] as String?,
    );
  }

  String get displayShiftTime {
    if (startShiftTime != null && endShiftTime != null) {
      return 'Shift Office Hour [$startShiftTime - $endShiftTime]';
    }
    return '-';
  }

  /// Extract HH:mm from datetime string "2026-01-28 15:47:57"
  String _extractTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '--:--';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      // If parsing fails, try to extract time portion directly
      if (dateTimeStr.contains(' ')) {
        final timePart = dateTimeStr.split(' ').last;
        if (timePart.contains(':')) {
          final parts = timePart.split(':');
          if (parts.length >= 2) {
            return '${parts[0]}:${parts[1]}';
          }
        }
      }
      return dateTimeStr;
    }
  }

  String get displayCheckIn => _extractTime(checkIn);
  String get displayCheckOut => _extractTime(checkOut);

  bool get hasCheckInError => checkIn == null;
  bool get hasCheckOutError => checkOut == null;
}

/// Response wrapper untuk detail overtime API
class OvertimeDetailResponse {
  final OvertimeEmployeeModel data;
  final OvertimeDetailModel detail;
  final List<OvertimeApproverModel> approverRequest;

  const OvertimeDetailResponse({
    required this.data,
    required this.detail,
    required this.approverRequest,
  });

  factory OvertimeDetailResponse.fromJson(Map<String, dynamic> json) {
    final records = json['records'] as Map<String, dynamic>;
    final approverRequestJson =
        records['approver_request'] as List<dynamic>? ?? [];
    final approverList = approverRequestJson
        .map(
          (json) =>
              OvertimeApproverModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
    return OvertimeDetailResponse(
      data: OvertimeEmployeeModel.fromJson(records['data']),
      detail: OvertimeDetailModel.fromJson(records['detail']),
      approverRequest: approverList,
    );
  }
}

class OvertimeApproverModel {
  final String? approverId;
  final String? approverName;
  final String? statusApproval;
  final String? approverProfile;
  final String? approverPosisition;
  final String? approvalAt;

  const OvertimeApproverModel({
    this.approverId,
    this.approverName,
    this.statusApproval,
    this.approverProfile,
    this.approverPosisition,
    this.approvalAt,
  });

  factory OvertimeApproverModel.fromJson(Map<String, dynamic> json) {
    return OvertimeApproverModel(
      approverId: json['approver_id'] as String?,
      approverName: json['approver_name'] as String?,
      statusApproval: json['status_approval'] as String?,
      approverProfile: json['approver_profile'] as String?,
      approverPosisition: json['approver_position'] as String?,
      approvalAt: json['approval_at'] as String?,
    );
  }

  String get displayApproverName => approverName ?? '-';
  String get displayStatusApproval => statusApproval ?? '-';

  bool get isApproved => statusApproval == 'APPROVE';
  bool get isRejected => statusApproval == 'REJECT';
  bool get isPending => statusApproval == 'PENDING';
}
