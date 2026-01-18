import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/constants/app_constants.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/routes/app_routes.dart';

class GantiPasswordScreen extends StatefulWidget {
  const GantiPasswordScreen({super.key});

  @override
  State<GantiPasswordScreen> createState() => _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends State<GantiPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  PasswordStrength get _passwordStrength {
    final password = _newPasswordController.text;
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
      _currentPasswordController.text.isNotEmpty &&
      _newPasswordController.text.length >= 8 &&
      _confirmPasswordController.text == _newPasswordController.text;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        newPasswordConfirmation: _confirmPasswordController.text,
      );

      if (mounted) {
        context.showSuccessSnackbar('Sukses! Silakan login kembali.');

        await context.read<AuthProvider>().logout();

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
          'Ganti Kata Sandi',
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
              _buildInfoCard(colors),
              SizedBox(height: 24.h),
              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Kata Sandi Lama',
                hint: 'Masukkan kata sandi lama',
                obscure: _obscureOldPassword,
                onToggle: () =>
                    setState(() => _obscureOldPassword = !_obscureOldPassword),
                colors: colors,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _newPasswordFocusNode.requestFocus(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata sandi lama wajib diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              _buildPasswordField(
                controller: _newPasswordController,
                focusNode: _newPasswordFocusNode,
                label: 'Kata Sandi Baru',
                hint: 'Minimal 8 karakter',
                obscure: _obscureNewPassword,
                onToggle: () =>
                    setState(() => _obscureNewPassword = !_obscureNewPassword),
                colors: colors,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    _confirmPasswordFocusNode.requestFocus(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata sandi baru wajib diisi';
                  }
                  if (value.length < 8) {
                    return 'Minimal 8 karakter';
                  }
                  return null;
                },
              ),
              if (_newPasswordController.text.isNotEmpty) ...[
                SizedBox(height: 12.h),
                _buildPasswordStrengthIndicator(colors),
              ],
              SizedBox(height: 20.h),
              _buildPasswordField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                label: 'Konfirmasi Kata Sandi Baru',
                hint: 'Ulangi kata sandi baru',
                obscure: _obscureConfirmPassword,
                onToggle: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
                colors: colors,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleSubmit(),
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
              SizedBox(height: 32.h),
              _buildSubmitButton(colors),
              SizedBox(height: 16.h),
              _buildPasswordTips(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeColors colors) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colors.primaryBlue, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Pastikan kata sandi baru Anda kuat dan mudah diingat.',
              style: AppTextStyles.small(colors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required ThemeColors colors,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySemiBold(colors.textPrimary)),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscure,
            textInputAction: textInputAction,
            onFieldSubmitted: onFieldSubmitted,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: AppTextStyles.body(colors.textPrimary),
            cursorColor: colors.primaryBlue,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.body(
                colors.textSubtitle.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.lock_outlined,
                color: colors.textSubtitle,
                size: 20.sp,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: colors.textSubtitle,
                  size: 20.sp,
                ),
                onPressed: onToggle,
              ),
              filled: true,
              fillColor: colors.inputFill,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: colors.primaryBlue, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
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

  Widget _buildSubmitButton(ThemeColors colors) {
    return SizedBox(
      width: double.infinity,
      child: Container(
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
            onTap: _isFormValid && !_isLoading ? _handleSubmit : null,
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
                        'Simpan Perubahan',
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
}

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
