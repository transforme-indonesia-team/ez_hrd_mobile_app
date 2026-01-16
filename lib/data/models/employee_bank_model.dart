/// Model untuk data bank karyawan
class EmployeeBankModel {
  final String? bankName;
  final String? accountName;
  final String? accountNumber;

  const EmployeeBankModel({
    this.bankName,
    this.accountName,
    this.accountNumber,
  });

  factory EmployeeBankModel.fromJson(Map<String, dynamic> json) {
    return EmployeeBankModel(
      bankName: json['bank_name'] as String?,
      accountName: json['bank_account_name_employee'] as String?,
      accountNumber: json['bank_account_number_employee'] as String?,
    );
  }

  String get displayBankName => bankName ?? '-';
  String get displayAccountName => accountName ?? '-';
  String get displayAccountNumber => accountNumber ?? '-';
}
