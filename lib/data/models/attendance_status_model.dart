import 'package:flutter/material.dart';
import 'package:hrd_app/core/theme/color_palette.dart';

class AttendanceStatusModel {
  final String value;
  final String label;
  final String attendanceStatusCode;
  final bool flagIncomplete;
  final String badgeColor;

  const AttendanceStatusModel({
    required this.value,
    required this.label,
    required this.attendanceStatusCode,
    required this.flagIncomplete,
    required this.badgeColor,
  });

  factory AttendanceStatusModel.fromJson(Map<String, dynamic> json) {
    final other = json['other'] as Map<String, dynamic>? ?? {};
    return AttendanceStatusModel(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
      attendanceStatusCode: other['attendance_status_code'] as String? ?? '',
      flagIncomplete: other['flag_incomplete'] as bool? ?? false,
      badgeColor: other['badge_color'] as String? ?? 'BLUE',
    );
  }

  /// Warna background badge
  Color get badgeBackgroundColor =>
      badgeColor == 'RED' ? ColorPalette.red50 : ColorPalette.blue50;

  /// Warna text badge
  Color get badgeTextColor =>
      badgeColor == 'RED' ? ColorPalette.red500 : ColorPalette.blue500;

  /// Parse list dari API response
  static List<AttendanceStatusModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => AttendanceStatusModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cari status berdasarkan attendance_status_code
  static AttendanceStatusModel? findByCode(
    List<AttendanceStatusModel> statuses,
    String? code,
  ) {
    if (code == null || code.isEmpty) return null;
    try {
      return statuses.firstWhere((s) => s.attendanceStatusCode == code);
    } catch (_) {
      return null;
    }
  }
}
