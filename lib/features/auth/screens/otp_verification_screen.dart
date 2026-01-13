import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/data/services/auth_service.dart';
import 'package:hrd_app/routes/app_routes.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String usernameOrEmail;

  const OtpVerificationScreen({super.key, required this.usernameOrEmail});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  static const int _cooldownDuration = 60;
  int _remainingSeconds = _cooldownDuration;
  Timer? _timer;
  bool _canResend = false;
  bool _isLoading = false;
  bool _isResending = false;

  String get _otpValue => _otpControllers.map((c) => c.text).join();
  bool get _isOtpComplete => _otpValue.length == 6;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _remainingSeconds = _cooldownDuration;
    _canResend = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _handleResend() async {
    if (!_canResend || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      final authService = AuthService();
      await authService.forgotPassword(usernameOrEmail: widget.usernameOrEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP telah dikirim ulang'),
            backgroundColor: Colors.green,
          ),
        );
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _handleVerify() async {
    if (!_isOtpComplete || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final response = await authService.verifyOtp(
        usernameOrEmail: widget.usernameOrEmail,
        otp: _otpValue,
      );

      if (mounted) {
        final original = response['original'] as Map<String, dynamic>?;
        final records = original?['records'] as Map<String, dynamic>?;
        final tokenReset = records?['token_reset'] as String? ?? '';

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.resetPassword,
          arguments: {'token_reset': tokenReset},
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                // Logo
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
                  'Verifikasi OTP',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Masukkan kode 6 digit yang telah dikirim ke ${widget.usernameOrEmail}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: colors.textSubtitle,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 40.h),
                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45.w,
                      height: 55.h,
                      child: TextFormField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                        cursorColor: colors.primaryBlue,
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: colors.inputFill,
                          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: _otpControllers[index].text.isNotEmpty
                                  ? colors.primaryBlue
                                  : colors.inputBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: _otpControllers[index].text.isNotEmpty
                                  ? colors.primaryBlue
                                  : colors.inputBorder,
                              width: _otpControllers[index].text.isNotEmpty
                                  ? 2
                                  : 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: colors.primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onOtpChanged(index, value),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 32.h),
                // Resend Timer
                Center(
                  child: _isResending
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : TextButton(
                          onPressed: _canResend ? _handleResend : null,
                          child: Text(
                            _canResend
                                ? 'Kirim Ulang OTP'
                                : 'Kirim ulang dalam ${_formatTime(_remainingSeconds)}',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: _canResend
                                  ? colors.linkColor
                                  : colors.textSubtitle,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 32.h),
                // Verify Button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isOtpComplete && !_isLoading
                          ? colors.buttonGradient
                          : colors.buttonGradientDisabled,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: _isOtpComplete && !_isLoading
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
                      onTap: _isOtpComplete && !_isLoading
                          ? _handleVerify
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
                                  'Verifikasi',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _isOtpComplete
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
                // Back to Login
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
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
