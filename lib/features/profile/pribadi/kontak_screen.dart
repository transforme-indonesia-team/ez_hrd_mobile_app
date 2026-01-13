import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/data/models/user_model.dart';
import 'package:provider/provider.dart';

class KontakScreen extends StatelessWidget {
  const KontakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kontak',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: _buildContent(colors, user),
      ),
    );
  }

  Widget _buildContent(dynamic colors, UserModel? user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16.h,
        children: [
          _buildInfoRow(colors, 'Telepon / Ponsel', user?.phone),
          _buildInfoRow(colors, 'Email', user?.email, isRequired: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    dynamic colors,
    String label,
    String? value, {
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: colors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value ?? '-',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: colors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
