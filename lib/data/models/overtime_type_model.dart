class OvertimeTypeModel {
  final String? id;
  final String? name;

  const OvertimeTypeModel({this.id, this.name});

  factory OvertimeTypeModel.fromJson(Map<String, dynamic> json) {
    return OvertimeTypeModel(
      id: json['overtime_type_id'] as String?,
      name: json['overtime_type_name'] as String?,
    );
  }

  String get displayName => name ?? '-';
}
