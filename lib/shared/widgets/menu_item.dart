import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';

/// Model untuk menu item dengan icon, title, dan callback
class MenuItemModel {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const MenuItemModel({
    required this.icon,
    required this.title,
    this.onTap,
  });
}

/// Reusable menu item widget dengan icon dan chevron
class MenuItem extends StatelessWidget {
  final MenuItemModel item;

  const MenuItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.background,
      child: ListTile(
        leading: Icon(item.icon, color: colors.textSecondary),
        title: Text(
          item.title,
          style: GoogleFonts.inter(fontSize: 16, color: colors.textPrimary),
        ),
        trailing: Icon(Icons.chevron_right, color: colors.inactiveGray),
        onTap: item.onTap,
      ),
    );
  }
}
