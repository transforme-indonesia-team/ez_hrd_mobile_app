import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';

enum LocationDialogType { gpsDisabled, permissionDenied }

class LocationPermissionDialog extends StatelessWidget {
  final LocationDialogType type;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const LocationPermissionDialog({
    super.key,
    required this.type,
    required this.onCancel,
    required this.onConfirm,
  });

  /// Show GPS disabled dialog
  static Future<void> showGPSDialog({
    required BuildContext context,
    required VoidCallback onOpenSettings,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => LocationPermissionDialog(
        type: LocationDialogType.gpsDisabled,
        onCancel: () => Navigator.pop(dialogContext),
        onConfirm: () {
          Navigator.pop(dialogContext);
          onOpenSettings();
        },
      ),
    );
  }

  /// Show permission denied dialog
  static Future<void> showPermissionDialog({
    required BuildContext context,
    required VoidCallback onOpenSettings,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => LocationPermissionDialog(
        type: LocationDialogType.permissionDenied,
        onCancel: () => Navigator.pop(dialogContext),
        onConfirm: () {
          Navigator.pop(dialogContext);
          onOpenSettings();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final config = _getDialogConfig(colors);

    return AlertDialog(
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      contentPadding: EdgeInsets.all(24.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(config, colors),
          SizedBox(height: 16.h),
          _buildTitle(config, colors),
          SizedBox(height: 8.h),
          _buildMessage(config, colors),
          SizedBox(height: 24.h),
          _buildActions(config, colors),
        ],
      ),
    );
  }

  Widget _buildIcon(_DialogConfig config, ThemeColors colors) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: config.iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(config.icon, color: config.iconColor, size: 40.sp),
    );
  }

  Widget _buildTitle(_DialogConfig config, ThemeColors colors) {
    return Text(
      config.title,
      style: GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildMessage(_DialogConfig config, ThemeColors colors) {
    return Text(
      config.message,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        color: colors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildActions(_DialogConfig config, ThemeColors colors) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              side: BorderSide(color: colors.divider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Nanti Saja',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryBlue,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            child: Text(
              config.confirmButtonText,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  _DialogConfig _getDialogConfig(ThemeColors colors) {
    switch (type) {
      case LocationDialogType.gpsDisabled:
        return _DialogConfig(
          icon: Icons.location_off_rounded,
          iconColor: colors.primaryBlue,
          title: 'Aktifkan Lokasi',
          message:
              'Untuk mencatat kehadiran, Anda perlu mengaktifkan layanan lokasi.',
          confirmButtonText: 'Aktifkan',
        );
      case LocationDialogType.permissionDenied:
        return _DialogConfig(
          icon: Icons.lock_outline_rounded,
          iconColor: colors.warning,
          title: 'Izin Lokasi Diperlukan',
          message: 'Silakan aktifkan izin lokasi di pengaturan aplikasi.',
          confirmButtonText: 'Buka Pengaturan',
        );
    }
  }
}

class _DialogConfig {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String confirmButtonText;

  const _DialogConfig({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.confirmButtonText,
  });
}
