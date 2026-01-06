import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/validators.dart';
import 'package:hrd_app/routes/app_routes.dart';

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
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Panggil AuthService untuk forgot password
        await Future.delayed(const Duration(seconds: 2)); // Simulasi

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Navigasi ke halaman Email Sent
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.emailSent,
            arguments: {'email': _usernameOrEmailController.text},
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        color: AppColors.textSubtitle.withOpacity(0.6),
        fontSize: 14,
      ),
      prefixIcon: Icon(prefixIcon, color: AppColors.textSubtitle, size: 20),
      filled: true,
      fillColor: AppColors.inputFillColor,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.inputBorderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.inputBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          // Logo
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo.jpeg',
                height: 90,
                width: 90,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            'Jangan khawatir! Kami \nmembantu Anda.',
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            'Masukkan nama pengguna atau email yang telah terdaftar di EZ HRD.',
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSubtitle,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          // Label
          Text(
            'Nama Pengguna / Email',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // Input field
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
              style: GoogleFonts.inter(fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: 'Masukkan Nama Pengguna atau Email',
                prefixIcon: Icons.person_outlined,
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
                foregroundColor: AppColors.primaryBlue,
              ),
              child: Text(
                'Kembali ke Login?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isFormValid && !_isLoading
                    ? AppColors.buttonGradient
                    : AppColors.buttonGradientDisabled,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isFormValid && !_isLoading
                  ? [
                      BoxShadow(
                        color: AppColors.buttonBlue.withOpacity(0.4),
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
                            'Kirim',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _isFormValid
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
