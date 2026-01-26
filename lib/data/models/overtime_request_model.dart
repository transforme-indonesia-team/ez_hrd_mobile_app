class OvertimeRequestModel {
  final String? id;
  final String? requestNumber;
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? cancellation;
  final String? overtimeType;
  final String? employeeName;

  const OvertimeRequestModel({
    this.id,
    this.requestNumber,
    this.description,
    this.startDate,
    this.endDate,
    this.status,
    this.cancellation,
    this.overtimeType,
    this.employeeName,
  });

  factory OvertimeRequestModel.fromJson(Map<String, dynamic> json) {
    return OvertimeRequestModel(
      id: json['overtime_id'] as String?,
      requestNumber: json['request_number'] as String?,
      description: json['description'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      status: json['status'] as String?,
      cancellation: json['cancellation'] as String?,
      overtimeType: json['overtime_type'] as String?,
      employeeName: json['employee_name'] as String?,
    );
  }

  String get displayRequestNumber => requestNumber ?? '-';
  String get displayDescription => description ?? '-';
  String get displayStartDate => startDate ?? '-';
  String get displayEndDate => endDate ?? '-';
  String get displayStatus => status ?? '-';
  String get displayCancellation => cancellation ?? '-';
  String get displayOvertimeType => overtimeType ?? '-';

  bool get isPending => status?.toLowerCase() == 'belum diverifikasi';
  bool get isApproved => status?.toLowerCase() == 'disetujui';
  bool get isRejected => status?.toLowerCase() == 'ditolak';
}
