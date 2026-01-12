import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? username;
  final String? phone;
  final String? token;
  final String? role;
  final String? company;
  final String? position;
  final String? organization;
  final String? employeeId;
  final String? employeeCode;
  final String? avatarUrl;
  final String? expiresAt;

  final String? nik;
  final String? placeOfBirth;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? religion;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.phone,
    this.token,
    this.role,
    this.company,
    this.position,
    this.organization,
    this.employeeId,
    this.employeeCode,
    this.avatarUrl,
    this.expiresAt,
    this.nik,
    this.placeOfBirth,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    this.religion,
  });

  factory UserModel.fromApiResponse(Map<String, dynamic> json) {
    final original = json['original'] as Map<String, dynamic>?;

    if (original == null) {
      throw Exception('Invalid response structure: missing "original"');
    }

    final records = original['records'] as Map<String, dynamic>?;

    if (records == null) {
      throw Exception('Invalid response structure: missing "records"');
    }

    final user = records['user'] as Map<String, dynamic>? ?? {};
    final employee = records['employee'] as Map<String, dynamic>? ?? {};
    final token = records['token'] as String?;
    final expiresAt = records['expires_at'] as String?;

    return UserModel(
      id: user['user_id']?.toString() ?? '',
      name: user['name'] ?? employee['employee_name'] ?? '',
      email: user['email'] ?? '',
      username: user['username'],
      phone: user['phone_user'],
      token: token,
      role: user['role'],
      company: employee['company_name'],
      position: employee['position_organization_name'],
      organization: employee['organization_name'],
      employeeId: employee['employee_id']?.toString(),
      employeeCode: employee['employee_code'],
      avatarUrl: user['profile'],
      expiresAt: expiresAt,
      nik: employee['nik'],
      placeOfBirth: employee['place_of_birth'],
      dateOfBirth: employee['date_of_birth'],
      gender: employee['gender'],
      maritalStatus: employee['marital_status'],
      religion: employee['employee_religion_name'],
    );
  }

  /// Legacy factory untuk backward compatibility
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Jika ada struktur 'original', gunakan fromApiResponse
    if (json.containsKey('original')) {
      return UserModel.fromApiResponse(json);
    }

    // Legacy format (untuk data dari SharedPreferences)
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      phone: json['phone'],
      token: json['token'],
      role: json['role'],
      company: json['company'],
      position: json['position'],
      organization: json['organization'],
      employeeId: json['employee_id']?.toString(),
      employeeCode: json['employee_code'],
      avatarUrl: json['avatar_url'],
      expiresAt: json['expires_at'],
      nik: json['nik'],
      placeOfBirth: json['place_of_birth'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      maritalStatus: json['marital_status'],
      religion: json['religion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'token': token,
      'role': role,
      'company': company,
      'position': position,
      'organization': organization,
      'employee_id': employeeId,
      'employee_code': employeeCode,
      'avatar_url': avatarUrl,
      'expires_at': expiresAt,
      'nik': nik,
      'place_of_birth': placeOfBirth,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'marital_status': maritalStatus,
      'religion': religion,
    };
  }

  /// Convert to JSON string for storage
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string (for loading from storage)
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    String? phone,
    String? token,
    String? role,
    String? company,
    String? position,
    String? organization,
    String? employeeId,
    String? employeeCode,
    String? avatarUrl,
    String? expiresAt,
    String? nik,
    String? placeOfBirth,
    String? dateOfBirth,
    String? gender,
    String? maritalStatus,
    String? religion,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      role: role ?? this.role,
      company: company ?? this.company,
      position: position ?? this.position,
      organization: organization ?? this.organization,
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      nik: nik ?? this.nik,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      religion: religion ?? this.religion,
    );
  }
}
