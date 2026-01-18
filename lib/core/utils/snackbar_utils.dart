import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/constants/app_constants.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, SnackbarType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, SnackbarType.error);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, SnackbarType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, SnackbarType.info);
  }

  static void showNotAvailable(BuildContext context, String featureName) {
    _show(context, '$featureName belum tersedia', SnackbarType.info);
  }

  static void _show(BuildContext context, String message, SnackbarType type) {
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
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: AppConstants.snackbarNormalSeconds),
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          icon: Icons.error_rounded,
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: AppConstants.snackbarLongSeconds),
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          icon: Icons.warning_rounded,
          backgroundColor: const Color(0xFFF59E0B),
          duration: const Duration(seconds: AppConstants.snackbarNormalSeconds),
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          icon: Icons.info_rounded,
          backgroundColor: const Color(0xFF3B82F6),
          duration: const Duration(seconds: AppConstants.snackbarShortSeconds),
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

  void showMenuNotAvailable(String menuName) =>
      AppSnackbar.showInfo(this, 'Menu "$menuName" belum tersedia');

  void showFeatureNotAvailable(String featureName) =>
      AppSnackbar.showInfo(this, '$featureName belum tersedia');

  void showSnackBarMessage(String message, {Duration? duration}) =>
      AppSnackbar.showInfo(this, message);
}
