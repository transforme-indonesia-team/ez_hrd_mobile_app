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
  final Color? backgroundColor;
  final Color? iconColor;

  const FiturCategoryModel({
    required this.name,
    required this.items,
    this.backgroundColor,
    this.iconColor,
  });
}

class FiturSectionModel {
  final String name;
  final List<FiturCategoryModel> categories;

  const FiturSectionModel({required this.name, required this.categories});
}
