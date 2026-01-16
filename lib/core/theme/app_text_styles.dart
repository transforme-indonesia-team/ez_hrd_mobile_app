import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized text styles for the app using Inter font
/// Replaces direct GoogleFonts.inter() calls throughout the codebase
class AppTextStyles {
  AppTextStyles._();

  // ============================================
  // HEADINGS
  // ============================================

  /// H1: 24sp, Bold
  static TextStyle h1(Color color) => GoogleFonts.inter(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: color,
  );

  /// H2: 20sp, SemiBold
  static TextStyle h2(Color color) => GoogleFonts.inter(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  /// H3: 18sp, SemiBold (used for screen titles)
  static TextStyle h3(Color color) => GoogleFonts.inter(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  /// H4: 16sp, SemiBold (used for section titles)
  static TextStyle h4(Color color) => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  // ============================================
  // BODY TEXT
  // ============================================

  /// Body Large: 16sp, Medium
  static TextStyle bodyLarge(Color color) => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  /// Body: 14sp, Regular
  static TextStyle body(Color color) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: color,
  );

  /// Body Medium: 14sp, Medium
  static TextStyle bodyMedium(Color color) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  /// Body SemiBold: 14sp, SemiBold
  static TextStyle bodySemiBold(Color color) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  // ============================================
  // SMALL TEXT
  // ============================================

  /// Small: 13sp, Regular
  static TextStyle small(Color color) => GoogleFonts.inter(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: color,
  );

  /// Small Medium: 13sp, Medium
  static TextStyle smallMedium(Color color) => GoogleFonts.inter(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  /// Caption: 12sp, Regular
  static TextStyle caption(Color color) => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: color,
  );

  /// Caption Medium: 12sp, Medium
  static TextStyle captionMedium(Color color) => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  // ============================================
  // EXTRA SMALL TEXT
  // ============================================

  /// XSmall: 11sp, Regular
  static TextStyle xSmall(Color color) => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    color: color,
  );

  /// XSmall Medium: 11sp, Medium
  static TextStyle xSmallMedium(Color color) => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  /// XXSmall: 10sp, Medium (for badges/labels)
  static TextStyle xxSmall(Color color) => GoogleFonts.inter(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  // ============================================
  // BUTTON TEXT
  // ============================================

  /// Button: 14sp, SemiBold
  static TextStyle button(Color color) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  /// Button Small: 12sp, Medium
  static TextStyle buttonSmall(Color color) => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );
}
