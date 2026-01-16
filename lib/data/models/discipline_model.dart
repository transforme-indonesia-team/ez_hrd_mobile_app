/// Model untuk data disiplin karyawan
class DisciplineModel {
  final String? typeName;
  final String? referenceNumber;
  final String? letterNumber;
  final String? startDate;
  final String? endDate;
  final String? remark;

  const DisciplineModel({
    this.typeName,
    this.referenceNumber,
    this.letterNumber,
    this.startDate,
    this.endDate,
    this.remark,
  });

  factory DisciplineModel.fromJson(Map<String, dynamic> json) {
    return DisciplineModel(
      typeName: json['discipline_type_name'] as String?,
      referenceNumber: json['reference_number_discipline'] as String?,
      letterNumber: json['discipline_letter_number'] as String?,
      startDate: json['start_date_discipline'] as String?,
      endDate: json['end_date_discipline'] as String?,
      remark: json['remark_discipline'] as String?,
    );
  }

  String get displayTypeName => typeName ?? '-';
  String get displayReferenceNumber => referenceNumber ?? '-';
  String get displayLetterNumber => letterNumber ?? '-';
  String get displayRemark => remark ?? '-';
}
