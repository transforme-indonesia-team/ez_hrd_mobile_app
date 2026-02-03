/// Model untuk data slip gaji karyawan
class PayslipModel {
  final String id;
  final String? employeeId;
  final String? employeeName;
  final int? periodMonth;
  final int? periodYear;

  const PayslipModel({
    required this.id,
    this.employeeId,
    this.employeeName,
    this.periodMonth,
    this.periodYear,
  });

  factory PayslipModel.fromJson(Map<String, dynamic> json) {
    return PayslipModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String?,
      employeeName: json['employee_name'] as String?,
      periodMonth: json['period_month'] as int?,
      periodYear: json['period_year'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'period_month': periodMonth,
      'period_year': periodYear,
    };
  }

  // ============ Helper getters untuk UI ============

  /// Display nama karyawan
  String get displayEmployeeName => employeeName ?? '-';

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
    final monthName = periodMonth! >= 1 && periodMonth! <= 12
        ? monthNames[periodMonth!]
        : '';
    return '$monthName $periodYear';
  }

  /// Display periode pendek "Des 2025"
  String get displayPeriodShort {
    if (periodMonth == null || periodYear == null) return '-';
    final monthShort = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final month = periodMonth! >= 1 && periodMonth! <= 12
        ? monthShort[periodMonth!]
        : '';
    return '$month $periodYear';
  }
}
