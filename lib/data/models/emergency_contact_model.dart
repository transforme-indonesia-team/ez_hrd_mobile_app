class EmergencyContactModel {
  final String? contactName;
  final String? contactPhone;
  final String? relationshipName;

  const EmergencyContactModel({
    this.contactName,
    this.contactPhone,
    this.relationshipName,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      relationshipName: json['relationship_name'] as String?,
    );
  }

  String get displayName => contactName ?? '-';
  String get displayPhone => contactPhone ?? '-';
  String get displayRelationship => relationshipName ?? '-';
}
