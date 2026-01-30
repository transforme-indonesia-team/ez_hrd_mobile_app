/// Model untuk saldo cuti karyawan yang diambil dari API relation LEAVE
/// Response endpoint: /employee/get-relation?relation=LEAVE
class EmployeeLeaveBalanceModel {
  final String id;
  final String? employeeId;
  final String? leaveTypeId;
  final String? generateType;
  final num? countEmployeeLeave;
  final num? remainingLeave;
  final bool? isGenerated;
  final String? startValidDateLeave;
  final String? endValidDateLeave;
  final String? nextValidDateLeave;
  final String? remarkEmployeeLeave;
  final bool? isActiveEmployeeLeave;
  final String? massiveLeaveId;
  final bool? generateMassiveLeave;
  final String? careerTransitionIdEmployeeLeave;
  final String? leaveTypeName;

  const EmployeeLeaveBalanceModel({
    required this.id,
    this.employeeId,
    this.leaveTypeId,
    this.generateType,
    this.countEmployeeLeave,
    this.remainingLeave,
    this.isGenerated,
    this.startValidDateLeave,
    this.endValidDateLeave,
    this.nextValidDateLeave,
    this.remarkEmployeeLeave,
    this.isActiveEmployeeLeave,
    this.massiveLeaveId,
    this.generateMassiveLeave,
    this.careerTransitionIdEmployeeLeave,
    this.leaveTypeName,
  });

  factory EmployeeLeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return EmployeeLeaveBalanceModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String?,
      leaveTypeId: json['leave_type_id'] as String?,
      generateType: json['generate_type'] as String?,
      countEmployeeLeave: json['count_employee_leave'] as num?,
      remainingLeave: json['remaining_leave'] as num?,
      isGenerated: json['is_generated'] as bool?,
      startValidDateLeave: json['start_valid_date_leave'] as String?,
      endValidDateLeave: json['end_valid_date_leave'] as String?,
      nextValidDateLeave: json['next_valid_date_leave'] as String?,
      remarkEmployeeLeave: json['remark_employee_leave'] as String?,
      isActiveEmployeeLeave: json['is_active_employee_leave'] as bool?,
      massiveLeaveId: json['massive_leave_id'] as String?,
      generateMassiveLeave: json['generate_massive_leave'] as bool?,
      careerTransitionIdEmployeeLeave:
          json['career_transition_id_employee_leave'] as String?,
      leaveTypeName: json['leave_type_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'leave_type_id': leaveTypeId,
      'generate_type': generateType,
      'count_employee_leave': countEmployeeLeave,
      'remaining_leave': remainingLeave,
      'is_generated': isGenerated,
      'start_valid_date_leave': startValidDateLeave,
      'end_valid_date_leave': endValidDateLeave,
      'next_valid_date_leave': nextValidDateLeave,
      'remark_employee_leave': remarkEmployeeLeave,
      'is_active_employee_leave': isActiveEmployeeLeave,
      'massive_leave_id': massiveLeaveId,
      'generate_massive_leave': generateMassiveLeave,
      'career_transition_id_employee_leave': careerTransitionIdEmployeeLeave,
      'leave_type_name': leaveTypeName,
    };
  }

  // ============ Helper getters untuk UI ============

  /// Display name untuk UI
  String get displayLeaveTypeName => leaveTypeName ?? '-';

  /// Display remaining leave sebagai string
  String get displayRemainingLeave {
    if (remainingLeave == null) return '0';
    // Format dengan 2 desimal jika ada decimal
    if (remainingLeave is int ||
        remainingLeave?.toDouble() == remainingLeave?.toInt()) {
      return remainingLeave!.toInt().toString();
    }
    return remainingLeave!.toStringAsFixed(2);
  }

  /// Display count employee leave sebagai string
  String get displayCountEmployeeLeave {
    if (countEmployeeLeave == null) return '0';
    if (countEmployeeLeave is int ||
        countEmployeeLeave?.toDouble() == countEmployeeLeave?.toInt()) {
      return countEmployeeLeave!.toInt().toString();
    }
    return countEmployeeLeave!.toStringAsFixed(2);
  }

  /// Parse dan return start valid date
  DateTime? get parsedStartValidDate {
    if (startValidDateLeave == null) return null;
    try {
      return DateTime.parse(startValidDateLeave!);
    } catch (e) {
      return null;
    }
  }

  /// Parse dan return end valid date
  DateTime? get parsedEndValidDate {
    if (endValidDateLeave == null) return null;
    try {
      return DateTime.parse(endValidDateLeave!);
    } catch (e) {
      return null;
    }
  }

  /// Check apakah leave balance ini aktif
  bool get isActive => isActiveEmployeeLeave ?? false;

  /// Check apakah masih valid (end date belum lewat)
  bool get isValid {
    final endDate = parsedEndValidDate;
    if (endDate == null) return false;
    return endDate.isAfter(DateTime.now());
  }
}
