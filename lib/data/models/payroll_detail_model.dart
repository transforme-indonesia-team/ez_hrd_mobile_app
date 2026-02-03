/// Model untuk detail slip gaji/payroll
class PayrollDetailModel {
  final int? periodMonth;
  final int? periodYear;
  final String? accessorName;
  final String? timestamp;
  final PayrollData? data;

  const PayrollDetailModel({
    this.periodMonth,
    this.periodYear,
    this.accessorName,
    this.timestamp,
    this.data,
  });

  factory PayrollDetailModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk parse int yang bisa datang sebagai String atau int
    int? parseIntOrNull(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return PayrollDetailModel(
      periodMonth: parseIntOrNull(json['period_month']),
      periodYear: parseIntOrNull(json['period_year']),
      accessorName: json['accessor_name'] as String?,
      timestamp: json['timestamp'] as String?,
      data: json['data'] != null
          ? PayrollData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Display periode dalam format "Desember 2025"
  String get displayPeriod {
    if (periodMonth == null || periodYear == null) return '-';
    final monthNames = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final month = periodMonth! >= 1 && periodMonth! <= 12
        ? monthNames[periodMonth!]
        : '';
    return '$month $periodYear';
  }
}

class PayrollData {
  final String? id;
  final String? employeeCode;
  final String? employeeName;
  final String? positionOrganizationName;
  final String? costCenterName;
  final String? taxRefNo;
  final String? taxStatus;
  final num? basicSalary;
  final List<DeductionItem> deductions;
  final List<AllowanceItem> allowances;
  final num? totalTaxAllowance;
  final num? totalTaxBorneByCompany;
  final num? totalTaxPenaltyBorneByCompany;
  final num? totalTax;
  final num? totalTaxPenalty;
  final String? employeeBankName;
  final String? bankAccountNameEmployee;
  final String? bankAccountNumberEmployee;
  final num? subTotalDeductions;
  final num? netSalary;
  final num? grossSalary;
  final num? totalEarning;
  final num? totalDeductions;

  const PayrollData({
    this.id,
    this.employeeCode,
    this.employeeName,
    this.positionOrganizationName,
    this.costCenterName,
    this.taxRefNo,
    this.taxStatus,
    this.basicSalary,
    this.deductions = const [],
    this.allowances = const [],
    this.totalTaxAllowance,
    this.totalTaxBorneByCompany,
    this.totalTaxPenaltyBorneByCompany,
    this.totalTax,
    this.totalTaxPenalty,
    this.employeeBankName,
    this.bankAccountNameEmployee,
    this.bankAccountNumberEmployee,
    this.subTotalDeductions,
    this.netSalary,
    this.grossSalary,
    this.totalEarning,
    this.totalDeductions,
  });

  factory PayrollData.fromJson(Map<String, dynamic> json) {
    return PayrollData(
      id: json['id'] as String?,
      employeeCode: json['employee_code'] as String?,
      employeeName: json['employee_name'] as String?,
      positionOrganizationName: json['position_organization_name'] as String?,
      costCenterName: json['cost_center_name'] as String?,
      taxRefNo: json['tax_ref_no'] as String?,
      taxStatus: json['tax_status'] as String?,
      basicSalary: json['basic_salary'] as num?,
      deductions:
          (json['deductions'] as List<dynamic>?)
              ?.map((e) => DeductionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      allowances:
          (json['allowances'] as List<dynamic>?)
              ?.map((e) => AllowanceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalTaxAllowance: json['total_tax_allowance'] as num?,
      totalTaxBorneByCompany: json['total_tax_borne_by_company'] as num?,
      totalTaxPenaltyBorneByCompany:
          json['total_tax_penalty_borne_by_company'] as num?,
      totalTax: json['total_tax'] as num?,
      totalTaxPenalty: json['total_tax_penalty'] as num?,
      employeeBankName: json['employee_bank_name'] as String?,
      bankAccountNameEmployee: json['bank_account_name_employee'] as String?,
      bankAccountNumberEmployee:
          json['bank_account_number_employee'] as String?,
      subTotalDeductions: json['sub_total_deductions'] as num?,
      netSalary: json['net_salary'] as num?,
      grossSalary: json['gross_salary'] as num?,
      totalEarning: json['total_earning'] as num?,
      totalDeductions: json['total_deductions'] as num?,
    );
  }
}

class DeductionItem {
  final String? deductionName;
  final num? deductionAmount;

  const DeductionItem({this.deductionName, this.deductionAmount});

  factory DeductionItem.fromJson(Map<String, dynamic> json) {
    return DeductionItem(
      deductionName: json['deduction_name'] as String?,
      deductionAmount: json['deduction_amount'] as num?,
    );
  }
}

class AllowanceItem {
  final String? allowanceName;
  final num? allowanceAmount;

  const AllowanceItem({this.allowanceName, this.allowanceAmount});

  factory AllowanceItem.fromJson(Map<String, dynamic> json) {
    return AllowanceItem(
      allowanceName: json['allowance_name'] as String?,
      allowanceAmount: json['allowance_amount'] as num?,
    );
  }
}
