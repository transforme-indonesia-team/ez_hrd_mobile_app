/// Model untuk data rekam medis karyawan
class MedicalRecordModel {
  // Physical measurements
  final String? height;
  final String? weight;
  final String? bloodType;
  final String? headSize;
  final String? shirtSize;
  final String? pantsSize;

  // Medical report
  final String? hasDisability;
  final bool? healthTest;
  final String? medicalTestReason;
  final String? hospitalizedReason;
  final String? medicalConditionToWatch;

  const MedicalRecordModel({
    this.height,
    this.weight,
    this.bloodType,
    this.headSize,
    this.shirtSize,
    this.pantsSize,
    this.hasDisability,
    this.healthTest,
    this.medicalTestReason,
    this.hospitalizedReason,
    this.medicalConditionToWatch,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      height: json['tinggi']?.toString(),
      weight: json['berat']?.toString(),
      bloodType: json['golongan_darah'] as String?,
      headSize: json['ukuran_kepala'] as String?,
      shirtSize: json['ukuran_baju'] as String?,
      pantsSize: json['ukuran_celana'] as String?,
      hasDisability: json['memiliki_disabilitas'] as String?,
      healthTest: json['test_kesehatan'] as bool?,
      medicalTestReason: json['alasan_test_medis'] as String?,
      hospitalizedReason: json['alasan_dirawat_dirumah_sakit'] as String?,
      medicalConditionToWatch:
          json['kondisi_medis_harus_diperhatikan'] as String?,
    );
  }

  String get displayHeight => height ?? '-';
  String get displayWeight => weight ?? '-';
  String get displayBloodType => bloodType ?? '-';
  String get displayHeadSize => headSize ?? '-';
  String get displayShirtSize => shirtSize ?? '-';
  String get displayPantsSize => pantsSize ?? '-';
  String get displayHasDisability => hasDisability ?? '-';
  String get displayHealthTest => healthTest == true ? 'Ya' : 'Tidak';
  String get displayMedicalTestReason => medicalTestReason ?? '-';
  String get displayHospitalizedReason => hospitalizedReason ?? '-';
  String get displayMedicalConditionToWatch =>
      medicalConditionToWatch ?? 'Tidak ada';
}
