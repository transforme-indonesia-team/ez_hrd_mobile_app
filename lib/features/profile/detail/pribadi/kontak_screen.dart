import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
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
        title: Text('Kontak', style: AppTextStyles.h3(colors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: _buildContent(colors, user),
      ),
    );
  }

  Widget _buildContent(ThemeColors colors, UserModel? user) {
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
    ThemeColors colors,
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
            style: AppTextStyles.bodyMedium(colors.textPrimary),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: AppTextStyles.bodyMedium(colors.error),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 4.h),
        Text(value ?? '-', style: AppTextStyles.body(colors.textPrimary)),
      ],
    );
  }
}
