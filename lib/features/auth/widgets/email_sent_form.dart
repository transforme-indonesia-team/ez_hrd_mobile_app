import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/routes/app_routes.dart';

class EmailSentForm extends StatefulWidget {
  final String email;

  const EmailSentForm({super.key, required this.email});

  @override
  State<EmailSentForm> createState() => _EmailSentFormState();
}

class _EmailSentFormState extends State<EmailSentForm> {
  static const int _cooldownDuration = 300;
  int _remainingSeconds = _cooldownDuration;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  void _handleResend() {
    if (_canResend) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email telah dikirim ulang'),
          backgroundColor: Colors.green,
        ),
      );
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/email.png',
              height: 140,
              width: 140,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'Email Terkirim',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Hai! Kami telah mengirimkan tautan ke ${widget.email}. Silakan periksa email Anda. Jika Anda tidak mendapatkan email dalam beberapa menit, periksa folder "junk mail" atau folder "spam" Anda.',
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colors.textSubtitle,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _canResend
                  ? colors.buttonGradient
                  : colors.buttonGradientDisabled,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _canResend
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
              onTap: _canResend ? _handleResend : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    _canResend
                        ? 'Kirim Ulang Permintaan'
                        : 'Kirim Ulang Permintaan ${_formatTime(_remainingSeconds)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _canResend
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: colors.linkColor,
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
      ],
    );
  }
}
