import 'package:flutter/material.dart';
import 'package:hrd_app/features/auth/screens/login_screen.dart';
import 'package:hrd_app/features/auth/screens/forgot_password_screen.dart';
import 'package:hrd_app/features/auth/screens/otp_verification_screen.dart';
import 'package:hrd_app/features/auth/screens/reset_password_screen.dart';
import 'package:hrd_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:hrd_app/features/profile/screens/profile_detail_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String dashboard = '/dashboard';
  static const String profileDetail = '/profile-detail';

  static const String initialRoute = login;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
          settings: settings,
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (context) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        final usernameOrEmail = args?['username_or_email'] as String? ?? '';
        return MaterialPageRoute(
          builder: (context) =>
              OtpVerificationScreen(usernameOrEmail: usernameOrEmail),
          settings: settings,
        );

      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        final tokenReset = args?['token_reset'] as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(tokenReset: tokenReset),
          settings: settings,
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
          settings: settings,
        );

      case profileDetail:
        return MaterialPageRoute(
          builder: (context) => const ProfileDetailScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('Route ${settings.name} tidak ditemukan')),
          ),
        );
    }
  }

  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> navigateAndReplace<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, void>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> navigateAndRemoveAll<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
