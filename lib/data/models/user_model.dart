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
  final String? nationality;
  final String? employeeAddress;
  final String? domicileAddress;
  final String? provinceName;
  final String? cityName;
  final String? subdistrictName;
  final String? postalName;
  final String? postalCode;

  final String? npwp;
  final String? taxRegisteredName;
  final String? npwpRegistrationData;

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
    this.nationality,
    this.employeeAddress,
    this.domicileAddress,
    this.provinceName,
    this.cityName,
    this.subdistrictName,
    this.postalName,
    this.postalCode,
    this.npwp,
    this.npwpRegistrationData,
    this.taxRegisteredName,
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
      nationality: employee['employee_nationality_name'],
      employeeAddress: employee['employee_address'],
      domicileAddress: employee['employee_domicile_address'],
      provinceName: employee['province_name'],
      cityName: employee['city_name'],
      subdistrictName: employee['subdistrict_name'],
      postalName: employee['postal_name'],
      postalCode: employee['postal_code']?.toString(),
      npwp: employee['npwp'],
      taxRegisteredName: employee['tax_registered_name'],
      npwpRegistrationData: employee['npwp_registration_data'],
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('original')) {
      return UserModel.fromApiResponse(json);
    }

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
      nationality: json['nationality'],
      employeeAddress: json['employee_address'],
      domicileAddress: json['domicile_address'],
      provinceName: json['province_name'],
      cityName: json['city_name'],
      subdistrictName: json['subdistrict_name'],
      postalName: json['postal_name'],
      postalCode: json['postal_code']?.toString(),
      npwp: json['npwp'],
      taxRegisteredName: json['tax_registered_name'],
      npwpRegistrationData: json['npwp_registration_data'],
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
      'nationality': nationality,
      'employee_address': employeeAddress,
      'domicile_address': domicileAddress,
      'province_name': provinceName,
      'city_name': cityName,
      'subdistrict_name': subdistrictName,
      'postal_name': postalName,
      'postal_code': postalCode,
      'npwp': npwp,
      'tax_registered_name': taxRegisteredName,
      'npwp_registration_data': npwpRegistrationData,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

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
    String? nationality,
    String? employeeAddress,
    String? domicileAddress,
    String? provinceName,
    String? cityName,
    String? subdistrictName,
    String? postalName,
    String? postalCode,
    String? npwp,
    String? taxRegisteredName,
    String? npwpRegistrationData,
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
      nationality: nationality ?? this.nationality,
      employeeAddress: employeeAddress ?? this.employeeAddress,
      domicileAddress: domicileAddress ?? this.domicileAddress,
      provinceName: provinceName ?? this.provinceName,
      cityName: cityName ?? this.cityName,
      subdistrictName: subdistrictName ?? this.subdistrictName,
      postalName: postalName ?? this.postalName,
      postalCode: postalCode ?? this.postalCode,
      npwp: npwp ?? this.npwp,
      taxRegisteredName: taxRegisteredName ?? this.taxRegisteredName,
      npwpRegistrationData: npwpRegistrationData ?? this.npwpRegistrationData,
    );
  }
}
