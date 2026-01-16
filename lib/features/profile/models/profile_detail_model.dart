import 'package:flutter/material.dart';
import 'package:hrd_app/data/models/user_model.dart';

class ProfileDetailModel {
  final String? username;
  final String name;
  final String role;
  final String? avatarUrl;
  final String? company;
  final String? organizationName;
  final List<SocialMediaLink> socialMediaLinks;

  const ProfileDetailModel({
    this.username,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.company,
    this.organizationName,
    this.socialMediaLinks = const [],
  });

  factory ProfileDetailModel.fromUser(UserModel? user) {
    if (user == null) {
      return const ProfileDetailModel(
        username: '-',
        name: 'User',
        role: 'Employee',
      );
    }
    return ProfileDetailModel(
      username: user.username ?? '-',
      name: user.name,
      role: user.role ?? 'Employee',
      avatarUrl: user.avatarUrl,
      company: user.company,
      organizationName: user.position,
    );
  }
}

class SocialMediaLink {
  final SocialMediaType type;
  final String url;

  const SocialMediaLink({required this.type, required this.url});
}

enum SocialMediaType { facebook, twitter, instagram, whatsapp, linkedin }

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

  String get subtitle => subItems.join(' , ');
}
