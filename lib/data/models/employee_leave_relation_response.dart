import 'package:hrd_app/data/models/employee_leave_balance_model.dart';

/// Model untuk response dari endpoint /employee/get-relation?relation=LEAVE
/// Response contoh:
/// {
///   "code": 200,
///   "status": true,
///   "message": "Data found.",
///   "records": {
///     "id": "...",
///     "employee_code": "...",
///     "employee_name": "...",
///     "is_active_employee": true,
///     "hire_date": "...",
///     "employee_leave": [...]
///   }
/// }
class EmployeeLeaveRelationResponse {
  final int? code;
  final bool? status;
  final String? message;
  final EmployeeLeaveRelationRecords? records;

  const EmployeeLeaveRelationResponse({
    this.code,
    this.status,
    this.message,
    this.records,
  });

  factory EmployeeLeaveRelationResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested 'original' key if present (from API wrapper)
    final data = json['original'] as Map<String, dynamic>? ?? json;

    return EmployeeLeaveRelationResponse(
      code: data['code'] as int?,
      status: data['status'] as bool?,
      message: data['message'] as String?,
      records: data['records'] != null
          ? EmployeeLeaveRelationRecords.fromJson(
              data['records'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Check apakah response sukses
  bool get isSuccess => status == true && code == 200;

  /// Get list of employee leave balances
  List<EmployeeLeaveBalanceModel> get leaveBalances =>
      records?.employeeLeave ?? [];
}

/// Model untuk records dalam response
class EmployeeLeaveRelationRecords {
  final String? id;
  final String? employeeCode;
  final String? employeeName;
  final bool? isActiveEmployee;
  final String? hireDate;
  final List<EmployeeLeaveBalanceModel>? employeeLeave;

  const EmployeeLeaveRelationRecords({
    this.id,
    this.employeeCode,
    this.employeeName,
    this.isActiveEmployee,
    this.hireDate,
    this.employeeLeave,
  });

  factory EmployeeLeaveRelationRecords.fromJson(Map<String, dynamic> json) {
    return EmployeeLeaveRelationRecords(
      id: json['id'] as String?,
      employeeCode: json['employee_code'] as String?,
      employeeName: json['employee_name'] as String?,
      isActiveEmployee: json['is_active_employee'] as bool?,
      hireDate: json['hire_date'] as String?,
      employeeLeave: (json['employee_leave'] as List<dynamic>?)
          ?.map(
            (e) =>
                EmployeeLeaveBalanceModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_code': employeeCode,
      'employee_name': employeeName,
      'is_active_employee': isActiveEmployee,
      'hire_date': hireDate,
      'employee_leave': employeeLeave?.map((e) => e.toJson()).toList(),
    };
  }

  /// Display employee name untuk UI
  String get displayEmployeeName => employeeName ?? '-';

  /// Display employee code untuk UI
  String get displayEmployeeCode => employeeCode ?? '-';

  /// Check apakah employee aktif
  bool get isActive => isActiveEmployee ?? false;

  /// Parse hire date sebagai DateTime
  DateTime? get parsedHireDate {
    if (hireDate == null) return null;
    try {
      return DateTime.parse(hireDate!);
    } catch (e) {
      return null;
    }
  }
}
