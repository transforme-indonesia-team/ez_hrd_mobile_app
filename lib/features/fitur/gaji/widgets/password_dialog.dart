import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

/// Dialog untuk input password slip gaji
class PasswordDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Future<bool> Function(String password, String passwordPayroll) onSubmit;

  const PasswordDialog({
    super.key,
    this.title = 'Masukkan Kata Sandi',
    this.subtitle,
    required this.onSubmit,
  });

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();

  /// Show dialog and return true if password is correct
  static Future<bool?> show({
    required BuildContext context,
    required Future<bool> Function(String password, String passwordPayroll)
    onSubmit,
    String title = 'Masukkan Kata Sandi',
    String? subtitle,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          PasswordDialog(title: title, subtitle: subtitle, onSubmit: onSubmit),
    );
  }
}

class _PasswordDialogState extends State<PasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passwordPayrollController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscurePayroll = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordPayrollController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onSubmit(
        _passwordController.text,
        _passwordPayrollController.text,
      );

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Kata sandi tidak valid';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.replaceFirst('Exception: ', '');
        }
        setState(() {
          _isLoading = false;
          _errorMessage = errorMsg;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      title: Text(widget.title, style: AppTextStyles.h4(colors.textPrimary)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.subtitle != null) ...[
              Text(
                widget.subtitle!,
                style: AppTextStyles.caption(colors.textSecondary),
              ),
              SizedBox(height: 16.h),
            ],

            // Password Login field
            Text(
              'Kata Sandi Login',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: _buildInputDecoration(
                colors,
                hint: 'Masukkan kata sandi login',
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              style: AppTextStyles.body(colors.textPrimary, fontSize: 14.sp),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kata sandi login wajib diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Password Payroll field
            Text(
              'Kata Sandi Slip Gaji',
              style: AppTextStyles.caption(colors.textSecondary),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _passwordPayrollController,
              obscureText: _obscurePayroll,
              decoration: _buildInputDecoration(
                colors,
                hint: 'Masukkan kata sandi slip gaji',
                obscure: _obscurePayroll,
                onToggle: () =>
                    setState(() => _obscurePayroll = !_obscurePayroll),
              ),
              style: AppTextStyles.body(colors.textPrimary, fontSize: 14.sp),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kata sandi slip gaji wajib diisi';
                }
                return null;
              },
            ),

            // Error message
            if (_errorMessage != null) ...[
              SizedBox(height: 12.h),
              Text(_errorMessage!, style: AppTextStyles.caption(colors.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: Text('Batal', style: AppTextStyles.body(colors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  height: 16.h,
                  width: 16.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Konfirmasi'),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    ThemeColors colors, {
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body(colors.textSecondary, fontSize: 14.sp),
      filled: true,
      fillColor: colors.surface,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: colors.textSecondary,
          size: 18.sp,
        ),
      ),
    );
  }
}
