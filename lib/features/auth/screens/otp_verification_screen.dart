import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/data/services/auth_service.dart';
import 'package:hrd_app/routes/app_routes.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String usernameOrEmail;
  final String? expiredAt;

  const OtpVerificationScreen({
    super.key,
    required this.usernameOrEmail,
    this.expiredAt,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  int _remainingSeconds = 0;
  Timer? _timer;
  bool _canResend = false;
  bool _isLoading = false;
  bool _isResending = false;

  bool get _isOtpComplete => _pinController.text.length == 6;

  @override
  void initState() {
    super.initState();
    _startCountdownFromExpiredAt(widget.expiredAt);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCountdownFromExpiredAt(String? expiredAt) {
    _timer?.cancel();
    _canResend = false;

    if (expiredAt != null) {
      try {
        final expiry = DateTime.parse(expiredAt);
        final now = DateTime.now();
        final difference = expiry.difference(now).inSeconds;

        if (difference > 0) {
          _remainingSeconds = difference;
        } else {
          _canResend = true;
          _remainingSeconds = 0;
          setState(() {});
          return;
        }
      } catch (e) {
        _remainingSeconds = 180;
      }
    } else {
      _remainingSeconds = 180;
    }

    setState(() {});

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

  Future<void> _handleResend() async {
    if (!_canResend || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      final authService = AuthService();
      final response = await authService.forgotPassword(
        usernameOrEmail: widget.usernameOrEmail,
      );

      if (mounted) {
        final original = response['original'] as Map<String, dynamic>?;
        final records = original?['records'] as Map<String, dynamic>?;
        final newExpiredAt = records?['expired_at'] as String?;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP telah dikirim ulang'),
            backgroundColor: Colors.green,
          ),
        );

        _startCountdownFromExpiredAt(newExpiredAt);
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
        otp: _pinController.text,
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
        _pinController.clear();
        _focusNode.requestFocus();

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

    final defaultPinTheme = PinTheme(
      width: 48.w,
      height: 56.h,
      textStyle: GoogleFonts.inter(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.inputBorder),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.primaryBlue, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: colors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.primaryBlue, width: 2),
      ),
    );

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
                // Pinput OTP Input
                Center(
                  child: Pinput(
                    length: 6,
                    controller: _pinController,
                    focusNode: _focusNode,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    separatorBuilder: (index) => SizedBox(width: 8.w),
                    onCompleted: (pin) => _handleVerify(),
                    onChanged: (value) => setState(() {}),
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          width: 22.w,
                          height: 2.h,
                          color: colors.primaryBlue,
                        ),
                      ],
                    ),
                    showCursor: true,
                    keyboardType: TextInputType.number,
                  ),
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
