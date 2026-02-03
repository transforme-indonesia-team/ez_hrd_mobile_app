import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/data/services/slip_gaji_service.dart';
import 'package:provider/provider.dart';

class KataSandiSlipGajiScreen extends StatefulWidget {
  const KataSandiSlipGajiScreen({super.key});

  @override
  State<KataSandiSlipGajiScreen> createState() =>
      _KataSandiSlipGajiScreenState();
}

class _KataSandiSlipGajiScreenState extends State<KataSandiSlipGajiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureAppPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  static const int _maxPasswordLength = 15;

  @override
  void dispose() {
    _appPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await SlipGajiService().createSlipGajiSandi(
        password: _appPasswordController.text,
        passwordPayroll: _newPasswordController.text,
        confirmPasswordPayroll: _confirmPasswordController.text,
      );

      if (mounted) {
        context.showSuccessSnackbar('Kata sandi slip gaji berhasil disimpan');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.replaceFirst('Exception: ', '');
        }
        context.showErrorSnackbar('Gagal menyimpan: $errorMsg');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kata Kunci Slip Gaji',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Name (read-only)
              _buildLabel(colors, 'Nama Karyawan'),
              SizedBox(height: 8.h),
              _buildReadOnlyField(colors, user?.name ?? '-'),
              SizedBox(height: 16.h),

              // App Login Password
              _buildLabel(colors, 'Kata Sandi Login Aplikasi'),
              SizedBox(height: 8.h),
              _buildPasswordField(
                colors,
                controller: _appPasswordController,
                hint: 'Kata Sandi Login Aplikasi',
                obscure: _obscureAppPassword,
                onToggle: () =>
                    setState(() => _obscureAppPassword = !_obscureAppPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata sandi login wajib diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // New Slip Gaji Password
              _buildLabel(colors, 'Kata Sandi Baru Slip Gaji'),
              SizedBox(height: 8.h),
              _buildPasswordField(
                colors,
                controller: _newPasswordController,
                hint: 'Kata Sandi Baru Slip Gaji',
                obscure: _obscureNewPassword,
                maxLength: _maxPasswordLength,
                onToggle: () =>
                    setState(() => _obscureNewPassword = !_obscureNewPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata sandi baru wajib diisi';
                  }
                  if (value.length > _maxPasswordLength) {
                    return 'Maksimal $_maxPasswordLength karakter';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Confirm Password
              _buildLabel(colors, 'Konfirmasi Kata Sandi Baru Slip Gaji'),
              SizedBox(height: 8.h),
              _buildPasswordField(
                colors,
                controller: _confirmPasswordController,
                hint: 'Konfirmasi Kata Sandi Baru Slip Gaji',
                obscure: _obscureConfirmPassword,
                maxLength: _maxPasswordLength,
                onToggle: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi kata sandi wajib diisi';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Kata sandi tidak cocok';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),

              // Submit Button
              _buildSubmitButton(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(ThemeColors colors, String text) {
    return Text(
      text,
      style: AppTextStyles.body(
        colors.textPrimary,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildReadOnlyField(ThemeColors colors, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.divider.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Text(
        value,
        style: AppTextStyles.body(colors.textPrimary, fontSize: 14.sp),
      ),
    );
  }

  Widget _buildPasswordField(
    ThemeColors colors, {
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(colors.textSecondary, fontSize: 14.sp),
        filled: true,
        fillColor: colors.background,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.primaryBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: colors.textSecondary,
            size: 20.sp,
          ),
        ),
      ),
      style: AppTextStyles.body(colors.textPrimary, fontSize: 14.sp),
      validator: validator,
    );
  }

  Widget _buildSubmitButton(ThemeColors colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.primaryBlue.withValues(alpha: 0.5),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: _isSubmitting
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text('Ajukan', style: AppTextStyles.button(Colors.white)),
      ),
    );
  }
}
