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
  final String? createdBy;
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
    this.createdBy,
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
      createdBy: json['created_by'] as String?,
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
      'created_by': createdBy,
      'company_name': companyName,
      'file_name_overtime': fileNameOvertime,
    };
  }

  String get displayOvertimeRequestNo => overtimeRequestNo ?? '-';
  String get displayEmployeeName => employeeName ?? '-';
  String get displayStatus => status ?? '-';
  String get displayDateOvertime => dateOvertime ?? '-';
  String get displayTimeRange =>
      '${startOvertime ?? '-'} - ${endOvertime ?? '-'}';

  bool get isDraft => status == 'DRAFT';
  bool get hasAttachment =>
      fileAttachmentOvertime != null && fileAttachmentOvertime!.isNotEmpty;
}
