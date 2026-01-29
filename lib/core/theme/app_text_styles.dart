import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle h1(Color color) => GoogleFonts.inter(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle h2(Color color) => GoogleFonts.inter(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle h3(Color color) => GoogleFonts.inter(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle h4(Color color) => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle bodyLarge(Color color) => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle body(Color color) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle bodyMedium(Color color) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle bodySemiBold(
    Color color, {
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.inter(
    fontSize: fontSize ?? 14.sp,
    fontWeight: fontWeight ?? FontWeight.w600,
    color: color,
  );

  static TextStyle small(Color color) => GoogleFonts.inter(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle smallMedium(Color color) => GoogleFonts.inter(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle caption(Color color) => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle captionMedium(Color color) => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle xSmall(Color color) => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle xSmallMedium(Color color) => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle xxSmall(Color color) => GoogleFonts.inter(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle button(Color color, {double? fontSize}) => GoogleFonts.inter(
    fontSize: fontSize ?? 14.sp,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle buttonSmall(Color color) => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: color,
  );
}
