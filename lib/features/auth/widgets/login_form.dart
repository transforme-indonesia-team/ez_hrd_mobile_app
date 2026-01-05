import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/utils/validators.dart';
import 'package:hrd_app/data/services/auth_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  // Modern Corporate Colors
  static const _primaryBlue = Color(0xFF2563EB);
  static const _darkBlue = Color(0xFF1D4ED8);
  static const _inputFillColor = Color(0xFFF8FAFC);
  static const _inputBorderColor = Color(0xFFE2E8F0);
  static const _subtitleColor = Color(0xFF6B7280);

  // App Version
  static const _appVersion = '1.0.0';

  // Cek apakah form valid untuk enable/disable button
  bool get _isFormValid =>
      _usernameController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await AuthService().login(
          username: _usernameController.text,
          password: _passwordController.text,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selamat datang, ${user['name']}!'),
              backgroundColor: Colors.green,
            ),
          );
          debugPrint('Login sukses! Token: ${user['token']}');
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

  // Modern input decoration with border
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: _subtitleColor.withValues(alpha: 0.6),
        fontSize: 14,
      ),
      prefixIcon: Icon(prefixIcon, color: _subtitleColor, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _inputFillColor,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _inputBorderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _inputBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryBlue, width: 2),
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
          // Extra space at top for better positioning
          const SizedBox(height: 20),

          // Logo
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/logo.jpeg',
                height: 90,
                width: 90,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Title with Poppins font
          Text(
            'EZ HRD APP',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _darkBlue,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Silakan login untuk melanjutkan',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: _subtitleColor),
          ),
          const SizedBox(height: 40),

          // Username Label
          Text(
            'Nama Pengguna',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Username TextField with shadow
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
              controller: _usernameController,
              keyboardType: TextInputType.text,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: 30,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: 'Masukkan nama pengguna',
                prefixIcon: Icons.person_outlined,
              ),
              validator: (value) => Validators.username(value, maxLength: 30),
            ),
          ),
          const SizedBox(height: 20),

          // Password Label
          Text(
            'Kata Sandi',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Password TextField with shadow
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
              controller: _passwordController,
              obscureText: _obscurePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: 20,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: 'Masukkan kata sandi',
                prefixIcon: Icons.lock_outlined,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _subtitleColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) => Validators.password(value, maxLength: 20),
            ),
          ),
          const SizedBox(height: 20),

          // Remember Me & Forgot Password Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // "Biarkan saya tetap masuk" checkbox
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 22,
                    width: 22,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: _primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(
                        color: _inputBorderColor,
                        width: 1.5,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _rememberMe = !_rememberMe;
                      });
                    },
                    child: Text(
                      'Biarkan saya tetap masuk',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 55, 58, 66),
                      ),
                    ),
                  ),
                ],
              ),
              // "Lupa Kata Sandi" link
              TextButton(
                onPressed: () {
                  // TODO: Navigate ke halaman forgot password
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: _primaryBlue,
                ),
                child: Text(
                  'Lupa Kata Sandi?',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Login Button with Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    _isFormValid && !_isLoading
                        ? [_primaryBlue, _darkBlue]
                        : [
                          _primaryBlue.withValues(alpha: 0.5),
                          _darkBlue.withValues(alpha: 0.5),
                        ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  _isFormValid && !_isLoading
                      ? [
                        BoxShadow(
                          color: _primaryBlue.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                      : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading || !_isFormValid ? null : _handleLogin,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              'Login',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
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
          const SizedBox(height: 32),

          // Version at bottom
          Text(
            'Versi $_appVersion',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color.fromARGB(
                255,
                23,
                24,
                27,
              ).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
