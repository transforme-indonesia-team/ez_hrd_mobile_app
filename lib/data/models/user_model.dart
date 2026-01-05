class UserModel {
  final int id;
  final String name;
  final String email;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  /// Convert dari JSON (response API) ke object UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
    );
  }

  /// Convert dari object UserModel ke JSON (untuk kirim ke API)
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'token': token};
  }
}
