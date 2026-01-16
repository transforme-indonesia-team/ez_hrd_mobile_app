/// Model untuk data penghargaan karyawan
class AwardModel {
  final String? typeName;
  final String? referenceNumber;
  final String? letterNumber;
  final String? startDate;
  final String? endDate;
  final String? remark;

  const AwardModel({
    this.typeName,
    this.referenceNumber,
    this.letterNumber,
    this.startDate,
    this.endDate,
    this.remark,
  });

  factory AwardModel.fromJson(Map<String, dynamic> json) {
    return AwardModel(
      typeName: json['award_type_name'] as String?,
      referenceNumber: json['reference_number_award'] as String?,
      letterNumber: json['award_letter_number'] as String?,
      startDate: json['start_date_award'] as String?,
      endDate: json['end_date_award'] as String?,
      remark: json['remark_award'] as String?,
    );
  }

  String get displayTypeName => typeName ?? '-';
  String get displayReferenceNumber => referenceNumber ?? '-';
  String get displayLetterNumber => letterNumber ?? '-';
  String get displayRemark => remark ?? '-';
}
