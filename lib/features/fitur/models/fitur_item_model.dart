import 'package:flutter/material.dart';

class FiturItemModel {
  final String id;
  final String title;
  final IconData icon;

  final String? route;

  const FiturItemModel({
    required this.id,
    required this.title,
    required this.icon,
    this.route,
  });
}

class FiturCategoryModel {
  final String name;
  final List<FiturItemModel> items;
  final List<FiturCategoryModel>? subCategories;
  final Color? backgroundColor;
  final Color? iconColor;

  const FiturCategoryModel({
    required this.name,
    this.items = const [],
    this.subCategories,
    this.backgroundColor,
    this.iconColor,
  });

  /// Semua items (flatten dari subCategories jika ada, otherwise direct items)
  List<FiturItemModel> get allItems {
    if (subCategories != null && subCategories!.isNotEmpty) {
      return subCategories!.expand((sub) => sub.items).toList();
    }
    return items;
  }
}

class FiturSectionModel {
  final String name;
  final List<FiturCategoryModel> categories;

  const FiturSectionModel({required this.name, required this.categories});
}
