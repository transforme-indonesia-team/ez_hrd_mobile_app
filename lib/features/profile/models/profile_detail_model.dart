import 'package:flutter/material.dart';
import 'package:hrd_app/data/models/user_model.dart';

/// Model untuk data profil karyawan
class ProfileDetailModel {
  final String employeeId;
  final String name;
  final String role;
  final String? avatarUrl;
  final String? company;
  final String? location;
  final List<SocialMediaLink> socialMediaLinks;

  const ProfileDetailModel({
    required this.employeeId,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.company,
    this.location,
    this.socialMediaLinks = const [],
  });

  /// Create from UserModel
  factory ProfileDetailModel.fromUser(UserModel? user) {
    if (user == null) {
      return const ProfileDetailModel(
        employeeId: '-',
        name: 'User',
        role: 'Employee',
      );
    }
    return ProfileDetailModel(
      employeeId: user.employeeId ?? '-',
      name: user.name,
      role: user.role ?? 'Employee',
      avatarUrl: user.avatarUrl,
      company: user.company,
      location: user.location,
    );
  }

  /// Get initials dari nama untuk avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }
}

/// Model untuk link media sosial
class SocialMediaLink {
  final SocialMediaType type;
  final String url;

  const SocialMediaLink({required this.type, required this.url});
}

/// Tipe media sosial yang didukung
enum SocialMediaType { facebook, twitter, instagram, whatsapp, linkedin }

/// Model untuk menu item profil dengan sub-items
class ProfileMenuItemModel {
  final IconData icon;
  final String title;
  final List<String> subItems;
  final VoidCallback? onTap;

  const ProfileMenuItemModel({
    required this.icon,
    required this.title,
    this.subItems = const [],
    this.onTap,
  });

  /// Get subtitle dari sub-items (comma separated)
  String get subtitle => subItems.join(' , ');
}
