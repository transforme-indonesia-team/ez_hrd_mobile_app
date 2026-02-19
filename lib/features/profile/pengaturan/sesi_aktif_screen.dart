import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

class _SessionData {
  final String platform;
  final String lastActive;
  final String version;
  final String device;
  final bool isCurrent;

  const _SessionData({
    required this.platform,
    required this.lastActive,
    required this.version,
    required this.device,
    this.isCurrent = false,
  });
}

class SesiAktifScreen extends StatefulWidget {
  const SesiAktifScreen({super.key});

  @override
  State<SesiAktifScreen> createState() => _SesiAktifScreenState();
}

class _SesiAktifScreenState extends State<SesiAktifScreen> {
  // Dummy data — nanti diganti dari API
  final List<_SessionData> _sessions = [
    const _SessionData(
      platform: 'Android',
      lastActive: '19 Feb 2026 11:30',
      version: 'EZ HRD 1.0.0 - 1',
      device: 'SM-A055F android 15',
      isCurrent: true,
    ),
    const _SessionData(
      platform: 'Safari - Browser 26.2',
      lastActive: '18 Feb 2026 09:15',
      version: 'EZ HRD Web',
      device: 'MacOS',
    ),
    const _SessionData(
      platform: 'Infinix X678B - android 14',
      lastActive: '15 Feb 2026 14:18',
      version: 'EZ HRD 1.0.0 - 1',
      device: 'Android',
    ),
    const _SessionData(
      platform: 'Chrome - Browser 120',
      lastActive: '10 Feb 2026 08:45',
      version: 'EZ HRD Web',
      device: 'Windows 11',
    ),
  ];

  _SessionData get _currentSession => _sessions.firstWhere((s) => s.isCurrent);

  List<_SessionData> get _otherSessions =>
      _sessions.where((s) => !s.isCurrent).toList();

  void _showLogoutConfirmation({
    required String message,
    required VoidCallback onConfirm,
  }) {
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Konfirmasi', style: AppTextStyles.h3(colors.textPrimary)),
        content: Text(message, style: AppTextStyles.body(colors.textSecondary)),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primaryBlue,
              side: BorderSide(color: colors.primaryBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Batalkan',
              style: AppTextStyles.button(colors.primaryBlue),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('OKE', style: AppTextStyles.button(Colors.white)),
          ),
        ],
      ),
    );
  }

  void _logoutSession(int index) {
    _showLogoutConfirmation(
      message: 'Apakah Anda yakin ingin keluar dari sesi ini?',
      onConfirm: () {
        setState(() {
          _sessions.removeAt(index);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sesi berhasil dihentikan')),
          );
        }
      },
    );
  }

  void _logoutAllOtherSessions() {
    _showLogoutConfirmation(
      message: 'Apakah Anda yakin ingin keluar dari semua sesi?',
      onConfirm: () {
        setState(() {
          _sessions.removeWhere((s) => !s.isCurrent);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Semua sesi lainnya berhasil dihentikan'),
            ),
          );
        }
      },
    );
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
        title: Text('Sesi Aktif', style: AppTextStyles.h3(colors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Sesi Sekarang ===
            Text('Sesi Sekarang', style: AppTextStyles.h4(colors.textPrimary)),
            SizedBox(height: 12.h),
            _buildCurrentSessionCard(colors),

            SizedBox(height: 24.h),

            // === Sesi Aktif Lainnya ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Sesi Aktif\nLainnya',
                  style: AppTextStyles.h4(colors.textPrimary),
                ),
                if (_otherSessions.isNotEmpty)
                  TextButton(
                    onPressed: _logoutAllOtherSessions,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                    ),
                    child: Text(
                      'Hentikan Semua Sesi\nLainnya',
                      style: AppTextStyles.captionMedium(Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            if (_otherSessions.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: Text(
                    'Tidak ada sesi aktif lainnya',
                    style: AppTextStyles.body(colors.textSecondary),
                  ),
                ),
              )
            else
              ...List.generate(_otherSessions.length, (i) {
                // Find the real index in original list to remove
                final session = _otherSessions[i];
                final realIndex = _sessions.indexOf(session);
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildOtherSessionCard(colors, session, realIndex),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSessionCard(ThemeColors colors) {
    final session = _currentSession;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform', style: AppTextStyles.caption(colors.textSecondary)),
          SizedBox(height: 2.h),
          Text(
            'Terakhir Aktif ${session.lastActive}',
            style: AppTextStyles.bodySemiBold(colors.textPrimary),
          ),
          SizedBox(height: 4.h),
          Text(
            session.version,
            style: AppTextStyles.caption(colors.textSecondary),
          ),
          Text(
            '${session.device} ${session.platform.toLowerCase().contains('android') ? '' : '- ${session.platform}'}',
            style: AppTextStyles.caption(colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSessionCard(
    ThemeColors colors,
    _SessionData session,
    int realIndex,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Terakhir Aktif  ',
                  style: AppTextStyles.captionMedium(colors.textPrimary),
                ),
                TextSpan(
                  text: session.lastActive,
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Versi  ',
                  style: AppTextStyles.captionMedium(colors.textPrimary),
                ),
                TextSpan(
                  text: session.version,
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Platform  ',
                  style: AppTextStyles.captionMedium(colors.textPrimary),
                ),
                TextSpan(
                  text: session.platform,
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _logoutSession(realIndex),
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  Icons.logout,
                  color: colors.primaryBlue,
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
