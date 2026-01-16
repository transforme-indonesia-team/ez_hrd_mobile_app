/// Model untuk data asuransi karyawan
class InsuranceModel {
  final String? insuranceName;
  final String? branchName;
  final String? branchCode;
  final String? branchAccount;
  final String? branchAddress;
  final String? insuranceDate;

  const InsuranceModel({
    this.insuranceName,
    this.branchName,
    this.branchCode,
    this.branchAccount,
    this.branchAddress,
    this.insuranceDate,
  });

  factory InsuranceModel.fromJson(Map<String, dynamic> json) {
    return InsuranceModel(
      insuranceName: json['insurance_name'] as String?,
      branchName: json['branch_name'] as String?,
      branchCode: json['branch_code'] as String?,
      branchAccount: json['branch_account'] as String?,
      branchAddress: json['branch_address'] as String?,
      insuranceDate: json['insurance_date'] as String?,
    );
  }

  String get displayInsuranceName => insuranceName ?? '-';
  String get displayBranchName => branchName ?? '-';
  String get displayBranchCode => branchCode ?? '-';
  String get displayBranchAccount => branchAccount ?? '-';
  String get displayBranchAddress => branchAddress ?? '-';
}
