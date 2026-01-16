import 'package:flutter/material.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

class MenuItemModel {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const MenuItemModel({required this.icon, required this.title, this.onTap});
}

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
        title: Text(item.title, style: AppTextStyles.h4(colors.textPrimary)),
        trailing: Icon(Icons.chevron_right, color: colors.inactiveGray),
        onTap: item.onTap,
      ),
    );
  }
}
