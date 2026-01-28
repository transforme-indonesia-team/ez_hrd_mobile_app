class CompanyModel {
  final String companyId;
  final String companyName;
  final String companyCode;

  const CompanyModel({
    required this.companyId,
    required this.companyName,
    required this.companyCode,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyId: (json['company_id'] is List)
          ? ((json['company_id'] as List).isNotEmpty
                ? (json['company_id'] as List).first.toString()
                : '')
          : json['company_id']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      companyCode: json['company_code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'company_name': companyName,
      'company_code': companyCode,
    };
  }

  @override
  String toString() => companyName;
}
