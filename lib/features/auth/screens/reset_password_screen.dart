import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/validators.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/core/constants/app_constants.dart';
import 'package:hrd_app/routes/app_routes.dart';
import 'package:provider/provider.dart';

enum PasswordStrength {
  none(0, 'Masukkan kata sandi', Colors.grey),
  weak(0.2, 'Lemah', Colors.red),
  fair(0.4, 'Cukup', Colors.orange),
  good(0.7, 'Baik', Colors.lightGreen),
  strong(1.0, 'Kuat', Colors.green);

  final double value;
  final String label;
  final Color color;

  const PasswordStrength(this.value, this.label, this.color);
}

class ResetPasswordScreen extends StatefulWidget {
  final String tokenReset;

  const ResetPasswordScreen({super.key, required this.tokenReset});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  PasswordStrength get _passwordStrength {
    final password = _passwordController.text;
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.weak;
    if (password.length < 8) return PasswordStrength.fair;

    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int score = 0;
    if (hasUpperCase) score++;
    if (hasLowerCase) score++;
    if (hasDigits) score++;
    if (hasSpecialChars) score++;
    if (password.length >= 12) score++;

    if (score >= 4) return PasswordStrength.strong;
    if (score >= 2) return PasswordStrength.good;
    return PasswordStrength.fair;
  }

  bool get _isFormValid =>
      _passwordController.text.isNotEmpty &&
      _passwordController.text.length >= 8 &&
      _confirmPasswordController.text == _passwordController.text;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<AuthProvider>().resetPassword(
        tokenReset: widget.tokenReset,
        newPassword: _passwordController.text,
        newPasswordConfirmation: _confirmPasswordController.text,
      );

      if (mounted) {
        context.showSuccessSnackbar(
          'Password berhasil direset! Silakan login.',
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        context.showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    required dynamic colors,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.body(colors.textSubtitle.withValues(alpha: 0.6)),
      prefixIcon: Icon(prefixIcon, color: colors.textSubtitle, size: 20.sp),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: colors.textSubtitle,
          size: 20.sp,
        ),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: colors.inputFill,
      counterText: '',
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colors.inputBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colors.inputBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(ThemeColors colors) {
    final strength = _passwordStrength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Kekuatan: ',
              style: AppTextStyles.caption(colors.textSubtitle),
            ),
            Text(
              strength.label,
              style: AppTextStyles.captionMedium(strength.color),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: strength.value),
            duration: const Duration(
              milliseconds: AppConstants.animationNormalMs,
            ),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: colors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(strength.color),
                minHeight: 6.h,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTips(ThemeColors colors) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tips Kata Sandi Kuat:',
            style: AppTextStyles.body(colors.textPrimary),
          ),
          SizedBox(height: 8.h),
          _buildTipItem('Minimal 8 karakter', colors),
          _buildTipItem('Kombinasi huruf besar dan kecil', colors),
          _buildTipItem('Sertakan angka (0-9)', colors),
          _buildTipItem('Gunakan karakter khusus (!@#\$%)', colors),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, ThemeColors colors) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16.sp,
            color: colors.textSubtitle,
          ),
          SizedBox(width: 8.w),
          Text(text, style: AppTextStyles.caption(colors.textSubtitle)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 90.w,
                        width: 90.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    'Reset Password',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(colors.textPrimary),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Buat password baru untuk akun Anda',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(colors.textSubtitle),
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    'Password Baru',
                    style: AppTextStyles.bodySemiBold(colors.textPrimary),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      maxLength: 20,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          _confirmPasswordFocusNode.requestFocus(),
                      style: AppTextStyles.body(colors.textPrimary),
                      cursorColor: colors.primaryBlue,
                      decoration: _buildInputDecoration(
                        hintText: 'Masukkan password baru',
                        prefixIcon: Icons.lock_outlined,
                        colors: colors,
                        obscure: _obscurePassword,
                        onToggle: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password baru wajib diisi';
                        }
                        if (value.length < 8) {
                          return 'Minimal 8 karakter';
                        }
                        return Validators.password(value, maxLength: 20);
                      },
                    ),
                  ),
                  if (_passwordController.text.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _buildPasswordStrengthIndicator(colors),
                  ],
                  SizedBox(height: 20.h),
                  Text(
                    'Konfirmasi Password',
                    style: AppTextStyles.bodySemiBold(colors.textPrimary),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      obscureText: _obscureConfirmPassword,
                      maxLength: 20,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleSubmit(),
                      style: AppTextStyles.body(colors.textPrimary),
                      cursorColor: colors.primaryBlue,
                      decoration: _buildInputDecoration(
                        hintText: 'Konfirmasi password baru',
                        prefixIcon: Icons.lock_outlined,
                        colors: colors,
                        obscure: _obscureConfirmPassword,
                        onToggle: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password wajib diisi';
                        }
                        if (value != _passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isFormValid && !_isLoading
                            ? colors.buttonGradient
                            : colors.buttonGradientDisabled,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: _isFormValid && !_isLoading
                          ? [
                              BoxShadow(
                                color: colors.buttonBlue.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isFormValid && !_isLoading
                            ? _handleSubmit
                            : null,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: _isLoading
                                ? SizedBox(
                                    height: 22.w,
                                    width: 22.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Reset Password',
                                    style: AppTextStyles.h4(
                                      _isFormValid
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: colors.linkColor,
                      ),
                      child: Text(
                        'Kembali ke Login',
                        style: AppTextStyles.body(Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildPasswordTips(colors),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
