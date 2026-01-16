/// Model untuk data pendidikan karyawan
class EducationModel {
  final String? institutionName;
  final String? levelName;
  final String? majorName;
  final String? startEducation;
  final String? endEducation;

  const EducationModel({
    this.institutionName,
    this.levelName,
    this.majorName,
    this.startEducation,
    this.endEducation,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      institutionName: json['education_institution_name'] as String?,
      levelName: json['education_level_name'] as String?,
      majorName: json['education_major_name'] as String?,
      startEducation: json['start_education']?.toString(),
      endEducation: json['end_education']?.toString(),
    );
  }

  String get displayInstitution => institutionName ?? '-';
  String get displayLevel => levelName ?? '-';
  String get displayMajor => majorName ?? '-';
  String get displayPeriod =>
      '${startEducation ?? '-'} - ${endEducation ?? '-'}';
}
