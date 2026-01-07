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
  final bool hasLainnya; // Flag untuk menampilkan tombol "Lainnya >"
  final String?
  lainnyaTitle; // Title yang ditampilkan di baris Lainnya (jika berbeda dari name)
  final List<FiturCategoryModel>
  directCategories; // Categories yang tampil langsung di main screen (bukan di Lainnya)

  const FiturSectionModel({
    required this.name,
    required this.categories,
    this.hasLainnya = false,
    this.lainnyaTitle,
    this.directCategories = const [],
  });
}
