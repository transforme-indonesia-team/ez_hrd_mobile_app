import 'package:flutter/material.dart';
import 'package:hrd_app/features/auth/screens/login_screen.dart';
import 'package:hrd_app/features/auth/screens/forgot_password_screen.dart';
import 'package:hrd_app/features/auth/screens/email_sent_screen.dart';
import 'package:hrd_app/features/dashboard/screens/dashboard_screen.dart';

/// Kelas untuk mengelola semua route dalam aplikasi.
/// Semua nama route dan mapping didefinisikan di sini untuk kemudahan maintenance.
class AppRoutes {
  // Private constructor - tidak bisa di-instantiate
  AppRoutes._();

  // ============================================
  // ROUTE NAMES
  // ============================================

  // Auth routes
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String emailSent = '/email-sent';
  static const String dashboard = '/dashboard';

  // Main app routes (tambahkan nanti)
  // static const String home = '/home';
  // static const String profile = '/profile';

  // ============================================
  // INITIAL ROUTE
  // ============================================
  static const String initialRoute = login;

  // ============================================
  // ROUTE GENERATOR
  // Digunakan untuk route dengan parameter
  // ============================================
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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

      case emailSent:
        // Ambil email dari arguments
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args?['email'] as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => EmailSentScreen(email: email),
          settings: settings,
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
          settings: settings,
        );

      default:
        // Route tidak ditemukan
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('Route ${settings.name} tidak ditemukan')),
          ),
        );
    }
  }

  // ============================================
  // NAVIGATION HELPERS
  // ============================================

  /// Navigasi ke halaman tertentu
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Navigasi dan replace halaman sekarang
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

  /// Navigasi dan hapus semua history
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

  /// Kembali ke halaman sebelumnya
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
