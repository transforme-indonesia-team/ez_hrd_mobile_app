import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

/// Tipe snackbar yang tersedia
enum SnackbarType { success, error, warning, info }

/// Global Snackbar utility untuk konsistensi UI di seluruh aplikasi
class AppSnackbar {
  AppSnackbar._();

  /// Menampilkan snackbar sukses
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, SnackbarType.success);
  }

  /// Menampilkan snackbar error
  static void showError(BuildContext context, String message) {
    _show(context, message, SnackbarType.error);
  }

  /// Menampilkan snackbar warning
  static void showWarning(BuildContext context, String message) {
    _show(context, message, SnackbarType.warning);
  }

  /// Menampilkan snackbar info
  static void showInfo(BuildContext context, String message) {
    _show(context, message, SnackbarType.info);
  }

  /// Menampilkan snackbar fitur belum tersedia
  static void showNotAvailable(BuildContext context, String featureName) {
    _show(context, '$featureName belum tersedia', SnackbarType.info);
  }

  /// Core method untuk menampilkan snackbar
  static void _show(BuildContext context, String message, SnackbarType type) {
    // Hapus snackbar yang sedang tampil sebelum menampilkan yang baru
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final config = _getConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(config.icon, color: Colors.white, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium(Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        duration: config.duration,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static _SnackbarConfig _getConfig(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          icon: Icons.check_circle_rounded,
          backgroundColor: const Color(0xFF10B981), // Green
          duration: const Duration(seconds: 3),
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          icon: Icons.error_rounded,
          backgroundColor: const Color(0xFFEF4444), // Red
          duration: const Duration(seconds: 4),
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          icon: Icons.warning_rounded,
          backgroundColor: const Color(0xFFF59E0B), // Orange/Amber
          duration: const Duration(seconds: 3),
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          icon: Icons.info_rounded,
          backgroundColor: const Color(0xFF3B82F6), // Blue
          duration: const Duration(seconds: 2),
        );
    }
  }
}

class _SnackbarConfig {
  final IconData icon;
  final Color backgroundColor;
  final Duration duration;

  const _SnackbarConfig({
    required this.icon,
    required this.backgroundColor,
    required this.duration,
  });
}

/// Extension untuk kemudahan akses dari BuildContext
extension SnackbarExtension on BuildContext {
  void showSuccessSnackbar(String message) =>
      AppSnackbar.showSuccess(this, message);

  void showErrorSnackbar(String message) =>
      AppSnackbar.showError(this, message);

  void showWarningSnackbar(String message) =>
      AppSnackbar.showWarning(this, message);

  void showInfoSnackbar(String message) => AppSnackbar.showInfo(this, message);

  void showNotAvailableSnackbar(String featureName) =>
      AppSnackbar.showNotAvailable(this, featureName);

  // Backward compatible methods
  void showMenuNotAvailable(String menuName) =>
      AppSnackbar.showInfo(this, 'Menu "$menuName" belum tersedia');

  void showFeatureNotAvailable(String featureName) =>
      AppSnackbar.showInfo(this, '$featureName belum tersedia');

  void showSnackBarMessage(String message, {Duration? duration}) =>
      AppSnackbar.showInfo(this, message);
}
