import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? token;
  final String? role;
  final String? company;
  final String? location;
  final String? employeeId;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.role,
    this.company,
    this.location,
    this.employeeId,
    this.avatarUrl,
  });

  /// Get initials from name for avatar display
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
      role: json['role'],
      company: json['company'],
      location: json['location'],
      employeeId: json['employee_id']?.toString(),
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'role': role,
      'company': company,
      'location': location,
      'employee_id': employeeId,
      'avatar_url': avatarUrl,
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
    int? id,
    String? name,
    String? email,
    String? token,
    String? role,
    String? company,
    String? location,
    String? employeeId,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      role: role ?? this.role,
      company: company ?? this.company,
      location: location ?? this.location,
      employeeId: employeeId ?? this.employeeId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
