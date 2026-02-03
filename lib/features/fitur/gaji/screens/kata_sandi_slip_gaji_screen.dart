import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/data/services/slip_gaji_service.dart';
import 'package:hrd_app/features/fitur/gaji/widgets/form_widgets.dart';
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
              ReadOnlyFormField(
                label: 'Nama Karyawan',
                value: user?.name ?? '-',
              ),
              SizedBox(height: 16.h),

              // App Login Password
              PasswordFormField(
                controller: _appPasswordController,
                label: 'Kata Sandi Login Aplikasi',
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
              PasswordFormField(
                controller: _newPasswordController,
                label: 'Kata Sandi Baru Slip Gaji',
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
              PasswordFormField(
                controller: _confirmPasswordController,
                label: 'Konfirmasi Kata Sandi Baru Slip Gaji',
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
              SubmitButton(
                isLoading: _isSubmitting,
                text: 'Ajukan',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
