class AppConstants {
  AppConstants._();

  // ============ Validation ============
  static const int usernameMaxLength = 30;
  static const int passwordMaxLength = 20;
  static const int passwordMinLength = 8;

  // ============ Timeouts ============
  static const int apiConnectTimeoutSeconds = 15;
  static const int apiReceiveTimeoutSeconds = 15;
  static const int locationTimeoutSeconds = 15;
  static const int geocodingTimeoutSeconds = 5;

  // ============ Design ============
  static const double designWidth = 375;
  static const double designHeight = 812;

  // ============ Navigation ============
  static const double bottomNavIconSize = 24;
  static const double bottomNavHeight = 60;

  // ============ Durations (milliseconds) ============
  static const int animationFastMs = 200;
  static const int animationNormalMs = 300;
  static const int animationSlowMs = 500;

  // ============ Durations (seconds) ============
  static const int snackbarShortSeconds = 2;
  static const int snackbarNormalSeconds = 3;
  static const int snackbarLongSeconds = 4;
  static const int otpTimerSeconds = 60;
  static const int simulatedDelaySeconds = 2;
  static const int lifecycleDelayMs = 300;

  // ============ Spacing ============
  static const double spacingXxs = 2;
  static const double spacingXs = 4;
  static const double spacingSm = 6;
  static const double spacingMd = 8;
  static const double spacingLg = 12;
  static const double spacingXl = 16;
  static const double spacingXxl = 20;
  static const double spacing2Xl = 24;
  static const double spacing3Xl = 32;
  static const double spacing4Xl = 40;
}
