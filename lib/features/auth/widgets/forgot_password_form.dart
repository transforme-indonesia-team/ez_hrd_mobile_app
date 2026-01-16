import 'package:flutter/material.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/validators.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/routes/app_routes.dart';
import 'package:provider/provider.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _usernameOrEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool get _isFormValid => _usernameOrEmailController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _usernameOrEmailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await context.read<AuthProvider>().forgotPassword(
        usernameOrEmail: _usernameOrEmailController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final original = response['original'] as Map<String, dynamic>?;
        final records = original?['records'] as Map<String, dynamic>?;
        final expiredAt = records?['expired_at'] as String?;

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.otpVerification,
          arguments: {
            'username_or_email': _usernameOrEmailController.text,
            'expired_at': expiredAt,
          },
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
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.body(colors.textSubtitle.withValues(alpha: 0.6)),
      prefixIcon: Icon(prefixIcon, color: colors.textSubtitle, size: 20),
      filled: true,
      fillColor: colors.inputFill,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.inputBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.inputBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo.png',
                height: 90,
                width: 90,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Jangan khawatir! Kami \nmembantu Anda.',
            textAlign: TextAlign.left,
            style: AppTextStyles.body(colors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Masukkan nama pengguna atau email yang telah terdaftar di EZ HRD.',
            textAlign: TextAlign.left,
            style: AppTextStyles.body(colors.textSubtitle),
          ),
          const SizedBox(height: 32),
          Text(
            'Nama Pengguna / Email',
            style: AppTextStyles.body(colors.textPrimary),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: _usernameOrEmailController,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: 50,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSubmit(),
              style: AppTextStyles.body(colors.textPrimary),
              decoration: _buildInputDecoration(
                hintText: 'Masukkan Nama Pengguna atau Email',
                prefixIcon: Icons.person_outlined,
                colors: colors,
              ),
              validator: (value) => Validators.required(
                value,
                fieldName: 'Nama Pengguna / Email',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: colors.linkColor,
              ),
              child: Text(
                'Kembali ke Login?',
                style: AppTextStyles.body(Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isFormValid && !_isLoading
                    ? colors.buttonGradient
                    : colors.buttonGradientDisabled,
              ),
              borderRadius: BorderRadius.circular(12),
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
                onTap: _isLoading || !_isFormValid ? null : _handleSubmit,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Kirim OTP',
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
        ],
      ),
    );
  }
}
